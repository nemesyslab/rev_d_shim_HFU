import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly, ReadWrite
import random
from fifo_async_base import fifo_async_base

async def setup_testbench(dut, rd_clk_period=4, wr_clk_period=4):
    tb = fifo_async_base(dut, rd_clk_period, wr_clk_period, time_unit="ns")
    return tb

# Test for FIFO reset with different clock periods, FIFO should be empty after reset and not full
@cocotb.test()
async def test_fifo_async_reset(dut):
    for i in range(10):
        rd_clk_period = random.randint(4, 20)
        wr_clk_period = random.randint(4, 20)

        tb = await setup_testbench(dut, rd_clk_period, wr_clk_period)
        tb.dut._log.info(f"STARTING TEST: Async FIFO Reset Iteration: {i+1}")
        await tb.start_clocks()

        # Perform reset
        wr_reset_task = cocotb.start_soon(tb.wr_reset())
        rd_reset_task = cocotb.start_soon(tb.rd_reset())
        await wr_reset_task
        await rd_reset_task

        # Verify FIFO state after reset
        await ReadOnly()
        assert dut.empty.value == 1, "FIFO should be empty after reset"
        assert dut.full.value == 0, "FIFO should not be full after reset"
        assert dut.almost_empty.value == 1, "FIFO should be almost empty after reset"
        assert dut.almost_full.value == 0, "FIFO should not be almost full after reset"

        await RisingEdge(dut.rd_clk)
        await RisingEdge(dut.wr_clk)
        await tb.kill_clocks()

# Test for basic write and read operations with different clock periods
@cocotb.test()
async def test_fifo_async_basic_write_read(dut):
    for i in range(10):
        rd_clk_period = random.randint(4, 20)
        wr_clk_period = random.randint(4, 20)

        tb = await setup_testbench(dut, rd_clk_period, wr_clk_period)
        tb.dut._log.info(f"STARTING TEST: Async FIFO Basic Write/Read Iteration: {i+1}")
        await tb.start_clocks()

        # Perform reset
        wr_reset_task = cocotb.start_soon(tb.wr_reset())
        rd_reset_task = cocotb.start_soon(tb.rd_reset())
        await wr_reset_task
        await rd_reset_task

        # Randomly generate data to write
        test_data = random.randint(0, tb.MAX_DATA_VALUE)

        # Start write and read tasks
        wr_task = cocotb.start_soon(tb.write(test_data))
        rd_task = cocotb.start_soon(tb.read())

        # Wait for write and read tasks to complete
        await wr_task
        read_data, expected_data = await rd_task
        assert read_data == expected_data, f"Read data {read_data} does not match expected {expected_data} and test data {test_data}"

        await ReadOnly()
        assert dut.empty.value == 1, "FIFO should be empty after read"

        await RisingEdge(dut.rd_clk)
        await RisingEdge(dut.wr_clk)
        await tb.kill_clocks()

