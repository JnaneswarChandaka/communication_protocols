# APB-UART Bridge

**Introduction**

---

The APB-UART design demonstrates a simple and clear communication parh between an Advanced Peripheral Bus (APB) interface and a UART-style peripheral. The purpose of this design is to show how a processor or controller can use the APB protocol to write data into a UART transmit register and read the same data back from a UART receive register using memory-mapped register access. The design operate using a 50 MHz system clock and models UART-side transfer unternally through register movement. In this implementation, data written through the APB interface is passed into the UART block, stored intenally, and made available at the receiver side for APB readback. The complete design consists of four modules: UART, APB_UART_Bridge, APB_UART_top, APB_UART_Bridge_tb.



**Design Code Description**

   The APB-UART design is organized as a simple hierarchical system with apb_uart_top as the top-level integration module. This top module instantiates apb_uart_bridge, which acts as the protocol interface between the APB bus and the UART register block. The APB bridge decodes APB read and write transactions, maps them to UART register operations, and returns the corresponding data to the APB master. The uart module used in this design is a simplified register-based UART model. Instead of implementing complete serial transmission and reception logic, it demonstrates UART behavior by storing transmitted data in an internal transmit register and forwarding it directly to a receive register for observation. This allows the design to clearly demonstrate APB write, APB read, register access, and end-to-end data flow without introducing unnecessary serial timing complexity. The APB interface provides memory-mapped access to UART registers using standard APB control and data signals such as PSEL, PENABLE, PWRITE, PADDR, PWDATA, PRDATA, and PREADY.

   
<img width="1306" height="728" alt="APB_UART_Bridge_block_diagram" src="https://github.com/user-attachments/assets/d0648d6a-afe0-467d-8446-10d4f9802768" />




1. **UART Module** (uart.v)
Description:

The uart module is a simplified UART-style peripheral used to demonstrate data movement between transmit and receive paths. It accepts transmit data (tx_data) and a write enable (tx_write) from the APB bridge. When valid transmit data is written, the UART captures the byte into an internal transmit register and immediately forwards it to the receive output register. This models UART communication in a simplified way for educational purposes. The module also generates two status signals: rx_ready, which indicates valid received data is available, and tx_busy, which indicates transmit activity.


2. **APB-UART Bridge** (apb_uart_bridge.v)
Description:

The apb_uart_bridge module acts as the communication bridge between the APB bus and the UART block. It receives APB transactions from the bus master and converts them into UART register operations. During a write transaction, the bridge decodes the APB address and writes the lower 8 bits of PWDATA into the UART transmit register. During a read transaction, it returns either received UART data or UART status depending on the selected address. The bridge handles APB protocol sequencing using PSEL, PENABLE, and PREADY, ensuring proper APB setup and access phases. This module is the key element that enables APB-controlled UART communication.

3. **Top-Level Integration** (apb_uart_top.v)
Description:

The apb_uart_top module is the top-level wrapper of the design. It connects the APB interface signals from the testbench or processor side to the apb_uart_bridge module. This module serves as the integration point for the complete APB-UART system and exposes a clean APB interface externally. Internally, it simply instantiates the APB bridge and connects all required signals.

4. **Testbench** (apb_uart_tb.v)
Description:

The apb_uart_tb module verifies the functionality of the APB-UART design. It generates the system clock, applies reset, performs APB write and read transactions, and prints results to the terminal. The testbench writes data into the UART transmit register through APB, then reads the UART receive register and status register to confirm proper operation. Two data transfers are performed (0xA5 and 0x3C) to demonstrate repeated APB-to-UART communication. The testbench also generates waveform output in apb_uart_dump.vcd for visual verification using GTKWave.
