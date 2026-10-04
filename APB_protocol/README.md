# APB interface



The Advanced Peripheral Bus (APB) protocol is a low-cost, low-power interface defined by ARM for connecting low-bandwidth peripherals to a system-on-chip (SoC). It's designed for simplicity, and transfers typically take at least two clock cycles. Here's an explanation of APB write and read transfers: Key APB Signals: 

● PCLK (Peripheral Clock): All transfers are synchronized to the rising edge of PCLK. 

● PRESETn (Peripheral Reset): Active LOW reset signal. 

● PADDR (Peripheral Address): The address bus, driven by the master to select a specific register or location within the slave. 

● PSELx (Peripheral Select): A dedicated select signal for each slave device. When PSELx for a specific slave is HIGH, that slave is selected for the current transfer. 

● PENABLE (Peripheral Enable): Indicates the start of the access phase of a transfer. It's asserted HIGH for at least one clock cycle during the access phase. 

● PWRITE (Peripheral Write): Indicates the type of transfer. HIGH for a write operation, LOW for a read operation. 

● PWDATA (Peripheral Write Data): The data bus for write operations, carrying data from the master to the slave. 

● PRDATA (Peripheral Read Data): The data bus for read operations, carrying data from the slave to the master. 

● PREADY (Peripheral Ready): Driven by the slave to indicate its readiness to complete the transfer. If LOW, the slave needs more time (inserts wait states). If HIGH, the transfer can complete in the next cycle. 

● PSLVERR (Peripheral Slave Error): Driven by the slave to indicate an error during the transfer. HIGH indicates an error. 

● PPROT (Peripheral Protection): (APB3/APB4 onwards) Provides transaction protection information (e.g., privilege level, secure/non-secure). 

● PSTRB (Peripheral Strobe): (APB4 onwards) Write strobes used for sparse data transfers, indicating which byte lanes are active during a write. 



<img width="717" height="582" alt="APB_interface_block_diagram" src="https://github.com/user-attachments/assets/70793037-6b0b-4a13-aaa0-1f3baf0704f6" />

---

APB Transfer Phases: 

Every APB transfer typically involves at least two clock cycles: 

1. SETUP Phase (T1):
   ○ The master initiates the transfer by asserting the relevant PSELx signal (to select the target slave).

   ○ It places the PADDR (address) on the address bus.

   ○ It asserts PWRITE (HIGH for write, LOW for read) to indicate the operation type.

   ○ For a write transfer, it also places the PWDATA on the write data bus.

   ○ This phase lasts for one clock cycle.
2. ACCESS Phase (T2 onwards):
   ○ In the next clock cycle (T2), the master asserts PENABLE HIGH. This signal indicates that the actual data transfer (access) is taking place.
   ○ The PADDR, PSELx, and PWRITE signals (and PWDATA for a write) must remain stable throughout the ACCESS phase until the transfer completes. ○ The slave controls the duration of the ACCESS phase using the PREADY signal.

---
**APB Write Transfer:**

1. SETUP Phase (T1):

   ○ Master asserts PSELx HIGH.

   ○ Master drives PADDR with the write address.

   ○ Master drives PWRITE HIGH.

   ○ Master drives PWDATA with the data to be written.
   
2. ACCESS Phase (T2):
   
   ○ Master asserts PENABLE HIGH.

   ○ The slave samples PADDR, PWRITE, and PWDATA on the rising edge of PCLK.

   ○ If the slave is ready to accept the data, it asserts PREADY HIGH.

   ○ If PREADY is HIGH at the rising edge of the next clock cycle (T3), the transfer completes successfully. The slave registers the data.

   ○ If the slave is not ready (e.g., busy), it can hold PREADY LOW. In this case, the master must keep PADDR, PSELx, PENABLE, PWRITE, and PWDATA stable, and the ACCESS phase extends for additional clock cycles until the slave asserts PREADY HIGH.

   ○ After the transfer completes (when PREADY goes HIGH), PENABLE is de-asserted. PSELx is also de-asserted unless another transfer to the same peripheral is immediately following.

   ○ The slave can optionally assert PSLVERR HIGH during the last cycle of the transfer to indicate an error.

---

**APB Read Transfer:**

1. SETUP Phase (T1):

   ○ Master asserts PSELx HIGH.

   ○ Master drives PADDR with the read address.

   ○ Master drives PWRITE LOW.

2. ACCESS Phase (T2):

   ○ Master asserts PENABLE HIGH.

   ○ The slave decodes the PADDR and PWRITE signals.

   ○ The slave retrieves the requested data from its internal registers or memory.

   ○ Once the data is ready, the slave drives the PRDATA bus with the read data and asserts PREADY HIGH.

   ○ If PREADY is HIGH at the rising edge of the next clock cycle (T3), the master samples PRDATA and the transfer completes successfully.

   ○ If the slave is not ready to provide data, it can hold PREADY LOW, extending the ACCESS phase until the data is available and PREADY is asserted HIGH.

   ○ After the transfer completes, PENABLE is de-asserted. PSELx is also de-asserted unless a subsequent transfer to the same peripheral is initiated.

   ○ The slave can assert PSLVERR HIGH during the last cycle to indicate a read error. 
