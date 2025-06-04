# SPI Configuration Synchronization Core
*Updated 2025-06-04*

The `shim_spi_cfg_sync` module synchronizes configuration signals from the AXI clock domain to the SPI clock domain.

## Inputs and Outputs

### Inputs

- **Clocks and Reset**
  - `spi_clk`: SPI clock signal.
  - `sync_resetn`: Active-low reset signal for just the synchronization logic.

- **AXI Domain Configuration Inputs**
  - `integ_thresh_avg [14:0]`: Integration threshold average configuration.
  - `integ_window [31:0]`: Integration window configuration.
  - `integ_en`: Integration enable signal.
  - `spi_en`: SPI enable signal.

### Outputs

- **SPI Domain Synchronized Outputs**
  - `integ_thresh_avg_stable [14:0]`: Synchronized and stable integration threshold average.
  - `integ_window_stable [31:0]`: Synchronized and stable integration window configuration.
  - `integ_en_stable`: Synchronized and stable integration enable signal.
  - `spi_en_stable`: Synchronized and stable SPI enable signal.

## Operation

- Each input signal from the AXI domain is synchronized to the SPI clock domain using a 3-stage synchronizer with a stability check.
- For each signal, a stability flag is generated to indicate when the synchronized value is stable.
- When all stability flags are asserted and `spi_en_sync` is high, the synchronized values are latched into the corresponding stable output registers.
- On synchronization reset (`sync_resetn` low), all stable output registers are cleared to their default values (zeros).

