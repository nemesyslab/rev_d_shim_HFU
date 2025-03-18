`timescale 1 ns / 1 ps

module hw_manager #(
  // Delays for the various timeouts, default to 1 second at 250 MHz
  parameter integer POWERON_WAIT   = 250000000, // Delay after releasing "shutdown_force" and "n_shutdown_rst"
  parameter integer BUF_LOAD_WAIT  = 250000000, // Full buffer load from DMA after "dma_en" is set
  parameter integer SPI_START_WAIT = 250000000, // SPI start after "spi_en" is set
  parameter integer SPI_STOP_WAIT  = 250000000  // SPI stop after "spi_en" is cleared
)
(
  input   wire          clk,
  input   wire          rst,

  // Inputs
  input   wire          sys_en,         // System enable
  input   wire          dac_buf_full,   // DAC buffer full
  input   wire          spi_running,    // SPI running
  input   wire          ext_shutdown,   // External shutdown
  input   wire          shutdown_sense, // Shutdown sense
  input   wire  [ 2:0]  sense_num,      // Shutdown sense number
  input   wire  [ 7:0]  over_thresh,    // Over threshold (per board)
  input   wire  [ 7:0]  dac_buf_underflow, // DAC buffer underflow (per board)
  input   wire  [ 7:0]  dac_buf_overflow,  // DAC buffer overflow (per board)
  input   wire  [ 7:0]  adc_buf_underflow, // ADC buffer underflow (per board)
  input   wire  [ 7:0]  adc_buf_overflow,  // ADC buffer overflow (per board)
  input   wire  [ 7:0]  premat_trig,    // Premature trigger (per board)
  input   wire  [ 7:0]  premat_dac_div, // Premature DAC division (per board)
  input   wire  [ 7:0]  premat_adc_div, // Premature ADC division (per board)
  input   wire  [ 7:0]  dac_thresh_underflow, // DAC threshold core FIFO underflow (per board)
  input   wire  [ 7:0]  dac_thresh_overflow, // DAC threshold core FIFO overflow (per board)
  input   wire  [ 7:0]  adc_thresh_underflow, // ADC threshold core FIFO underflow (per board)
  input   wire  [ 7:0]  adc_thresh_overflow, // ADC threshold core FIFO overflow (per board)


  // Outputs
  output  reg           sys_rst,        // System reset
  output  reg           dma_en,         // DMA enable
  output  reg           spi_en,         // SPI subsystem enable
  output  reg           trig_en,        // Trigger enable
  output  reg           shutdown_force, // Shutdown force
  output  reg           n_shutdown_rst, // Shutdown reset (negated)
  output  wire  [31:0]  status_word,    // Status - Status word
  output  reg           ps_interrupt    // Interrupt signal
);

  // Internal signals
  reg [3:0]  state;       // State machine state
  reg [31:0] timer;       // Timer for various timeouts
  reg [2:0]  board_num;   // Status - Board number (if applicable)
  reg [24:0] status_code; // Status - Status code

  // Concatenated status word
  assign status_word = {board_num, status_code, state};

  // State encoding
  localparam  IDLE      = 4'd1,
              POWERON   = 4'd2,
              START_DMA = 4'd3,
              START_SPI = 4'd4,
              RUNNING   = 4'd5,
              HALTED    = 4'd6;

  // Status codes
  localparam  STATUS_OK                   = 25'd1,
              STATUS_PS_SHUTDOWN          = 25'd2,
              STATUS_DAC_BUF_FILL_TIMEOUT = 25'd3,
              STATUS_SPI_START_TIMEOUT    = 25'd4,
              STATUS_OVER_THRESH          = 25'd5,
              STATUS_SHUTDOWN_SENSE       = 25'd6,
              STATUS_EXT_SHUTDOWN         = 25'd7,
              STATUS_DAC_BUF_UNDERFLOW    = 25'd8,
              STATUS_DAC_BUF_OVERFLOW     = 25'd9,
              STATUS_ADC_BUF_UNDERFLOW    = 25'd10,
              STATUS_ADC_BUF_OVERFLOW     = 25'd11,
              STATUS_PREMAT_TRIG          = 25'd12,
              STATUS_PREMAT_DAC_DIV       = 25'd13,
              STATUS_PREMAT_ADC_DIV       = 25'd14,
              STATUS_DAC_THRESH_UNDERFLOW = 25'd15,
              STATUS_DAC_THRESH_OVERFLOW  = 25'd16,
              STATUS_ADC_THRESH_UNDERFLOW = 25'd17,
              STATUS_ADC_THRESH_OVERFLOW  = 25'd18;

  // Main state machine
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= IDLE;
      timer <= 0;
      sys_rst <= 1;
      shutdown_force <= 1;
      n_shutdown_rst <= 1;
      dma_en <= 0;
      spi_en <= 0;
      trig_en <= 0;
      status_code <= STATUS_OK;
      board_num <= 0;
      ps_interrupt <= 0;
    end else begin

      // State machine
      case (state)

        // Idle state, hardware shut down, waiting for system enable to go high
        // When enabled, remove the system reset and shutdown force, reset the shutdown
        IDLE: begin
          if (sys_en) begin
            state <= POWERON;
            timer <= 0;
            sys_rst <= 0;
            shutdown_force <= 0;
            n_shutdown_rst <= 0;
          end // if (sys_en)
          
        end // IDLE

        // Hold the shutdown latch reset high (n_shutdown_rst low) while we wait for the system to power on
        // Once the power is on, release the shutdown latch reset and start the DMA
        POWERON: begin
          if (timer >= POWERON_WAIT) begin
            state <= START_DMA;
            timer <= 0;
            n_shutdown_rst <= 1;
          end else begin
            timer <= timer + 1;
          end // if (timer >= POWERON_WAIT)
        end // POWERON

        // Wait for the DAC buffer to fill from the DMA before starting the SPI
        // If the buffer doesn't fill in time, halt the system
        START_DMA: begin
          if (dac_buf_full) begin
            state <= START_SPI;
            timer <= 0;
            spi_en <= 1;
          end else if (timer >= BUF_LOAD_WAIT) begin
            state <= HALTED;
            timer <= 0;
            sys_rst <= 1;
            shutdown_force <= 1;
            dma_en <= 0;
            status_code <= STATUS_DAC_BUF_FILL_TIMEOUT;
            ps_interrupt <= 1;
          end else begin
            timer <= timer + 1;
          end // if (dac_buf_full)
        end // START_DMA

        // Wait for the SPI subsystem to start before running the system
        // If the SPI subsystem doesn't start in time, halt the system
        START_SPI: begin
          if (spi_running) begin
            state <= RUNNING;
            timer <= 0;
            trig_en <= 1;
            ps_interrupt <= 1;
          end else if (timer >= SPI_START_WAIT) begin
            state <= HALTED;
            timer <= 0;
            sys_rst <= 1;
            shutdown_force <= 1;
            dma_en <= 0;
            spi_en <= 0;
            status_code <= STATUS_SPI_START_TIMEOUT;
            ps_interrupt <= 1;
          end else begin
            timer <= timer + 1;
          end // if (spi_running)
        end // START_SPI

        // Main running state, check for various error conditions or shutdowns
        RUNNING: begin
          // Reset the interrupt if needed
          if (ps_interrupt) begin
            ps_interrupt <= 0;
          end // if (ps_interrupt)

          // Error/halt state check
          if (!sys_en 
              || over_thresh 
              || shutdown_sense 
              || ext_shutdown 
              || dac_buf_underflow 
              || dac_buf_overflow 
              || adc_buf_overflow 
              || adc_buf_underflow 
              || premat_trig 
              || premat_dac_div 
              || premat_adc_div
              || dac_thresh_overflow
              || adc_thresh_overflow
              || dac_thresh_underflow
              || adc_thresh_underflow
              ) begin
            // Set the status code and halt the system
            state <= HALTED;
            timer <= 0;
            sys_rst <= 1;
            shutdown_force <= 1;
            dma_en <= 0;
            spi_en <= 0;
            trig_en <= 0;
            ps_interrupt <= 1;

            // Processing system shutdown
            if (!sys_en) status_code <= STATUS_PS_SHUTDOWN;

            // Integrator core over threshold
            else if (over_thresh) begin
              status_code <= STATUS_OVER_THRESH;
              board_num <= extract_board_num(over_thresh);
            end // if (over_thresh)

            // Hardware shutdown sense core detected a shutdown
            else if (shutdown_sense) begin
              status_code <= STATUS_SHUTDOWN_SENSE;
              board_num <= sense_num;
            end // if (shutdown_sense)

            // External shutdown
            else if (ext_shutdown) status_code <= STATUS_EXT_SHUTDOWN;

            // DAC buffer underflow
            else if (dac_buf_underflow) begin
              status_code <= STATUS_DAC_BUF_UNDERFLOW;
              board_num <= extract_board_num(dac_buf_underflow);
            end // if (dac_buf_underflow)

            // DAC buffer overflow
            else if (dac_buf_overflow) begin
              status_code <= STATUS_DAC_BUF_OVERFLOW;
              board_num <= extract_board_num(dac_buf_overflow);
            end // if (dac_buf_overflow)

            // ADC buffer underflow
            else if (adc_buf_underflow) begin
              status_code <= STATUS_ADC_BUF_UNDERFLOW;
              board_num <= extract_board_num(adc_buf_underflow);
            end // if (adc_buf_underflow)

            // ADC buffer overflow
            else if (adc_buf_overflow) begin
              status_code <= STATUS_ADC_BUF_OVERFLOW;
              board_num <= extract_board_num(adc_buf_overflow);
            end // if (adc_buf_overflow)

            // Premature trigger (trigger occurred before the DAC was pre-loaded and ready)
            else if (premat_trig) begin
              status_code <= STATUS_PREMAT_TRIG;
              board_num <= extract_board_num(premat_trig);
            end // if (premat_trig)

            // Premature DAC divider (DAC transfer took longer than the DAC divider)
            else if (premat_dac_div) begin
              status_code <= STATUS_PREMAT_DAC_DIV;
              board_num <= extract_board_num(premat_dac_div);
            end // if (premat_dac_div)

            // Premature ADC division (ADC transfer took longer than the ADC divider)
            else if (premat_adc_div) begin
              status_code <= STATUS_PREMAT_ADC_DIV;
              board_num <= extract_board_num(premat_adc_div);
            end // if (premat_adc_div)

            // DAC threshold core FIFO underflow
            else if (dac_thresh_underflow) begin
              status_code <= STATUS_DAC_THRESH_UNDERFLOW;
              board_num <= extract_board_num(dac_thresh_underflow);
            end // if (dac_thresh_underflow)

            // DAC threshold core FIFO overflow
            else if (dac_thresh_overflow) begin
              status_code <= STATUS_DAC_THRESH_OVERFLOW;
              board_num <= extract_board_num(dac_thresh_overflow);
            end // if (dac_thresh_overflow)

            // ADC threshold core FIFO underflow
            else if (adc_thresh_underflow) begin
              status_code <= STATUS_ADC_THRESH_UNDERFLOW;
              board_num <= extract_board_num(adc_thresh_underflow);
            end // if (adc_thresh_underflow)

            // ADC threshold core FIFO overflow
            else if (adc_thresh_overflow) begin
              status_code <= STATUS_ADC_THRESH_OVERFLOW;
              board_num <= extract_board_num(adc_thresh_overflow);
            end // if (adc_thresh_overflow)

          end // Error/halt state check
        end // RUNNING

        // Wait in the halted state until the system enable goes low
        HALTED: begin
          // Reset the interrupt if needed
          if (ps_interrupt) begin
            ps_interrupt <= 0;
          end // if (ps_interrupt)
          // If the system enable goes low, go to IDLE and clear the status code
          if (~sys_en) begin 
            state <= IDLE;
            status_code <= STATUS_OK;
            board_num <= 0;
          end
        end // HALTED

      endcase // case (state)
    end // if (rst) else
  end // always @(posedge clk or posedge rst)

  // Function to extract the board number from an 8-bit signal
  function [2:0] extract_board_num;
    input [7:0] signal;
    begin
      case (1'b1)
        signal[0]: extract_board_num = 3'd0;
        signal[1]: extract_board_num = 3'd1;
        signal[2]: extract_board_num = 3'd2;
        signal[3]: extract_board_num = 3'd3;
        signal[4]: extract_board_num = 3'd4;
        signal[5]: extract_board_num = 3'd5;
        signal[6]: extract_board_num = 3'd6;
        signal[7]: extract_board_num = 3'd7;
        default: extract_board_num = 3'd0;
      endcase
    end
  endfunction

endmodule
