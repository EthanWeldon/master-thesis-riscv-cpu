// cpu_test_pkg.sv
// Shared types, constants, and utility tasks for the baseline test suite.
// Import with: import cpu_test_pkg::*;

package cpu_test_pkg;

    // ----------------------------------------------------------------
    // Constants
    // ----------------------------------------------------------------

    // Maximum number of tests the YAML parser will load
    parameter int MAX_TESTS = 32;

    // Maximum number of expected register checks per test
    parameter int MAX_REG_CHECKS = 16;

    // Maximum number of expected memory-word checks per test
    parameter int MAX_MEM_CHECKS = 8;

    // YAML parser line/string buffer width (characters)
    parameter int LINE_BUF = 256;

    // Register index that signals test termination when written with STOP_VAL
    parameter int  STOP_REG = 12;
    parameter logic [31:0] STOP_VAL = 32'h0000_0001;

    // Default cycle budget if max_cycles is absent from the YAML
    parameter int DEFAULT_MAX_CYCLES = 200;

    // ----------------------------------------------------------------
    // Types
    // ----------------------------------------------------------------

    // One expected register check: {register index, expected value}
    typedef struct packed {
        logic [4:0]  addr;
        logic [31:0] value;
    } reg_check_t;

    // One expected memory-word check: {byte address, expected value}
    typedef struct packed {
        logic [31:0] addr;
        logic [31:0] value;
    } mem_check_t;

    // Complete descriptor for a single test loaded from the YAML
    typedef struct {
        string       test_name;
        string       program_image;
        bit          enabled;
        int          max_cycles;
        int          num_reg_checks;
        reg_check_t  reg_checks [MAX_REG_CHECKS];
        int          num_mem_checks;
        mem_check_t  mem_checks [MAX_MEM_CHECKS];
    } test_descriptor_t;

    // ----------------------------------------------------------------
    // Utility: hex string -> 32-bit value
    // Handles "0x..." and plain hex strings.
    // ----------------------------------------------------------------
    function automatic logic [31:0] parse_hex32(input string s);
        logic [31:0] val;
        int start;
        start = 0;
        // strip leading whitespace and optional 0x prefix
        while (start < s.len() && (s[start] == " " || s[start] == "\t"))
            start++;
        if (start + 1 < s.len() && s[start] == "0" &&
                (s[start+1] == "x" || s[start+1] == "X"))
            start += 2;
        val = 0;
        for (int i = start; i < s.len(); i++) begin
            automatic byte c = s[i];
            if (c >= "0" && c <= "9")      val = (val << 4) | (c - "0");
            else if (c >= "a" && c <= "f") val = (val << 4) | (c - "a" + 10);
            else if (c >= "A" && c <= "F") val = (val << 4) | (c - "A" + 10);
            else break; // stop at non-hex char (handles trailing whitespace/newline)
        end
        return val;
    endfunction

    // ----------------------------------------------------------------
    // Utility: decimal string -> int
    // ----------------------------------------------------------------
    function automatic int parse_int(input string s);
        int val;
        int start;
        start = 0;
        while (start < s.len() && (s[start] == " " || s[start] == "\t"))
            start++;
        val = 0;
        for (int i = start; i < s.len(); i++) begin
            automatic byte c = s[i];
            if (c >= "0" && c <= "9") val = val * 10 + (c - "0");
            else break;
        end
        return val;
    endfunction

    // ----------------------------------------------------------------
    // Utility: trim leading/trailing whitespace from a string
    // ----------------------------------------------------------------
    function automatic string strtrim(input string s);
        int lo, hi;
        lo = 0;
        hi = s.len() - 1;
        while (lo <= hi && (s[lo] == " " || s[lo] == "\t" ||
                            s[lo] == "\n" || s[lo] == "\r"))
            lo++;
        while (hi >= lo && (s[hi] == " " || s[hi] == "\t" ||
                            s[hi] == "\n" || s[hi] == "\r"))
            hi--;
        if (hi < lo) return "";
        return s.substr(lo, hi);
    endfunction

    // ----------------------------------------------------------------
    // Utility: return substring between first ':' and end of line,
    // trimmed.  Returns "" if no ':' found.
    // ----------------------------------------------------------------
    function automatic string after_colon(input string s);
        int pos;
        pos = -1;
        for (int i = 0; i < s.len(); i++)
            if (s[i] == ":") begin pos = i; break; end
        if (pos < 0) return "";
        return strtrim(s.substr(pos + 1, s.len() - 1));
    endfunction

    // ----------------------------------------------------------------
    // Utility: check whether string s contains substring sub
    // ----------------------------------------------------------------
    function automatic bit str_contains(input string s, input string sub);
        int slen, sublen;
        slen   = s.len();
        sublen = sub.len();
        if (sublen == 0) return 1;
        for (int i = 0; i <= slen - sublen; i++) begin
            automatic bit match = 1;
            for (int j = 0; j < sublen; j++)
                if (s[i+j] != sub[j]) begin match = 0; break; end
            if (match) return 1;
        end
        return 0;
    endfunction

endpackage
