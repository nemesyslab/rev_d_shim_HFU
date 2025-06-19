import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly, ReadWrite
import random
from fifo_async_count_base import fifo_async_count_base

async def setup_testbench(dut, rd_clk_period=4, wr_clk_period=4):
    tb = fifo_async_count_base(dut, rd_clk_period, wr_clk_period, time_unit="ns")
    return tb

# Test for FIFO reset, FIFO should be empty after reset and not full
@cocotb.test()
async def test_fifo_async_count_reset(dut):
    rd_clk_period = random.randint(4, 20)
    wr_clk_period = random.randint(4, 20)

    tb = await setup_testbench(dut, rd_clk_period, wr_clk_period)
    tb.dut._log.info("STARTING TEST: Async FIFO Reset")

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