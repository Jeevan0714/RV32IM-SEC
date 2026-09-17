// ============================================================
// Grain-128 Keystream — 8-bit Parallel Output
//
// Generates 8 keystream bits per clock by combinationally
// unrolling 8 cipher steps from the current LFSR/NFSR state.
//
// Also outputs L_next / N_next (8-step-ahead states) so the
// LFSR and NFSR registers advance by 8 on every posedge.
//
// Bit assignment (MSB-first, big-endian):
//   Z[7] = keystream bit from current state  S_0 (L,  N)
//   Z[6] = keystream bit from next state     S_1 (Ls1,Ns1)
//   Z[5] = keystream bit from state          S_2 (Ls2,Ns2)
//   ...
//   Z[0] = keystream bit from state          S_7 (Ls7,Ns7)
//
// LFSR feedback:  f = Ls[127]^Ls[120]^Ls[89]^Ls[57]^Ls[46]^Ls[31]
// NFSR feedback:  g = Ls[127] ^ Ns[127] ^ Ns[101] ^ Ns[71] ^ Ns[36] ^ Ns[31]
//                   ^ (Ns[124].Ns[60]) ^ (Ns[116].Ns[114]) ^ (Ns[110].Ns[109])
//                   ^ (Ns[100].Ns[68]) ^ (Ns[87].Ns[79]) ^ (Ns[66].Ns[62])
//                   ^ (Ns[59].Ns[43])
// Output h-fn:  h = (x0.x1)^(x2.x3)^(x4.x5)^(x6.x7)^(x0.x4.x8)
//              Z  = h ^ Ls[34] ^ Ns[125]^Ns[112]^Ns[91]^Ns[82]^Ns[63]^Ns[54]^Ns[38]
// ============================================================

module KEYSTREAM (
    input  wire [127:0] L,        // Current LFSR state (S_0)
    input  wire [127:0] N,        // Current NFSR state (S_0)
    output wire [7:0]   Z,        // 8 parallel keystream bits (Z[7]=first)
    output wire [127:0] L_next,   // LFSR state after 8 steps (loaded by LFSR reg)
    output wire [127:0] N_next    // NFSR state after 8 steps (loaded by NFSR reg)
);

// ----------------------------------------------------------------
// LFSR: Unroll 8 steps — purely combinational wire chain
// Each step: Lsk+1 = {Lsk[126:0], Lsk[127]^Lsk[120]^Lsk[89]^Lsk[57]^Lsk[46]^Lsk[31]}
// ----------------------------------------------------------------
wire Lfb0 = L[127]   ^ L[120]   ^ L[89]   ^ L[57]   ^ L[46]   ^ L[31];
wire [127:0] Ls1 = {L[126:0],   Lfb0};

wire Lfb1 = Ls1[127] ^ Ls1[120] ^ Ls1[89] ^ Ls1[57] ^ Ls1[46] ^ Ls1[31];
wire [127:0] Ls2 = {Ls1[126:0], Lfb1};

wire Lfb2 = Ls2[127] ^ Ls2[120] ^ Ls2[89] ^ Ls2[57] ^ Ls2[46] ^ Ls2[31];
wire [127:0] Ls3 = {Ls2[126:0], Lfb2};

wire Lfb3 = Ls3[127] ^ Ls3[120] ^ Ls3[89] ^ Ls3[57] ^ Ls3[46] ^ Ls3[31];
wire [127:0] Ls4 = {Ls3[126:0], Lfb3};

wire Lfb4 = Ls4[127] ^ Ls4[120] ^ Ls4[89] ^ Ls4[57] ^ Ls4[46] ^ Ls4[31];
wire [127:0] Ls5 = {Ls4[126:0], Lfb4};

wire Lfb5 = Ls5[127] ^ Ls5[120] ^ Ls5[89] ^ Ls5[57] ^ Ls5[46] ^ Ls5[31];
wire [127:0] Ls6 = {Ls5[126:0], Lfb5};

wire Lfb6 = Ls6[127] ^ Ls6[120] ^ Ls6[89] ^ Ls6[57] ^ Ls6[46] ^ Ls6[31];
wire [127:0] Ls7 = {Ls6[126:0], Lfb6};

wire Lfb7 = Ls7[127] ^ Ls7[120] ^ Ls7[89] ^ Ls7[57] ^ Ls7[46] ^ Ls7[31];
assign L_next = {Ls7[126:0], Lfb7};   // S_8 — what LFSR register loads next clock

// ----------------------------------------------------------------
// NFSR: Unroll 8 steps — uses corresponding LFSR state for coupling
// ----------------------------------------------------------------
wire Nfb0 = L[127]
          ^ N[127]   ^ N[101]   ^ N[71]   ^ N[36]   ^ N[31]
          ^ (N[124]  & N[60])   ^ (N[116]  & N[114]) ^ (N[110]  & N[109])
          ^ (N[100]  & N[68])   ^ (N[87]   & N[79])  ^ (N[66]   & N[62])
          ^ (N[59]   & N[43]);
wire [127:0] Ns1 = {N[126:0], Nfb0};

wire Nfb1 = Ls1[127]
          ^ Ns1[127] ^ Ns1[101] ^ Ns1[71] ^ Ns1[36] ^ Ns1[31]
          ^ (Ns1[124] & Ns1[60])  ^ (Ns1[116] & Ns1[114]) ^ (Ns1[110] & Ns1[109])
          ^ (Ns1[100] & Ns1[68])  ^ (Ns1[87]  & Ns1[79])  ^ (Ns1[66]  & Ns1[62])
          ^ (Ns1[59]  & Ns1[43]);
wire [127:0] Ns2 = {Ns1[126:0], Nfb1};

wire Nfb2 = Ls2[127]
          ^ Ns2[127] ^ Ns2[101] ^ Ns2[71] ^ Ns2[36] ^ Ns2[31]
          ^ (Ns2[124] & Ns2[60])  ^ (Ns2[116] & Ns2[114]) ^ (Ns2[110] & Ns2[109])
          ^ (Ns2[100] & Ns2[68])  ^ (Ns2[87]  & Ns2[79])  ^ (Ns2[66]  & Ns2[62])
          ^ (Ns2[59]  & Ns2[43]);
wire [127:0] Ns3 = {Ns2[126:0], Nfb2};

wire Nfb3 = Ls3[127]
          ^ Ns3[127] ^ Ns3[101] ^ Ns3[71] ^ Ns3[36] ^ Ns3[31]
          ^ (Ns3[124] & Ns3[60])  ^ (Ns3[116] & Ns3[114]) ^ (Ns3[110] & Ns3[109])
          ^ (Ns3[100] & Ns3[68])  ^ (Ns3[87]  & Ns3[79])  ^ (Ns3[66]  & Ns3[62])
          ^ (Ns3[59]  & Ns3[43]);
wire [127:0] Ns4 = {Ns3[126:0], Nfb3};

wire Nfb4 = Ls4[127]
          ^ Ns4[127] ^ Ns4[101] ^ Ns4[71] ^ Ns4[36] ^ Ns4[31]
          ^ (Ns4[124] & Ns4[60])  ^ (Ns4[116] & Ns4[114]) ^ (Ns4[110] & Ns4[109])
          ^ (Ns4[100] & Ns4[68])  ^ (Ns4[87]  & Ns4[79])  ^ (Ns4[66]  & Ns4[62])
          ^ (Ns4[59]  & Ns4[43]);
wire [127:0] Ns5 = {Ns4[126:0], Nfb4};

wire Nfb5 = Ls5[127]
          ^ Ns5[127] ^ Ns5[101] ^ Ns5[71] ^ Ns5[36] ^ Ns5[31]
          ^ (Ns5[124] & Ns5[60])  ^ (Ns5[116] & Ns5[114]) ^ (Ns5[110] & Ns5[109])
          ^ (Ns5[100] & Ns5[68])  ^ (Ns5[87]  & Ns5[79])  ^ (Ns5[66]  & Ns5[62])
          ^ (Ns5[59]  & Ns5[43]);
wire [127:0] Ns6 = {Ns5[126:0], Nfb5};

wire Nfb6 = Ls6[127]
          ^ Ns6[127] ^ Ns6[101] ^ Ns6[71] ^ Ns6[36] ^ Ns6[31]
          ^ (Ns6[124] & Ns6[60])  ^ (Ns6[116] & Ns6[114]) ^ (Ns6[110] & Ns6[109])
          ^ (Ns6[100] & Ns6[68])  ^ (Ns6[87]  & Ns6[79])  ^ (Ns6[66]  & Ns6[62])
          ^ (Ns6[59]  & Ns6[43]);
wire [127:0] Ns7 = {Ns6[126:0], Nfb6};

wire Nfb7 = Ls7[127]
          ^ Ns7[127] ^ Ns7[101] ^ Ns7[71] ^ Ns7[36] ^ Ns7[31]
          ^ (Ns7[124] & Ns7[60])  ^ (Ns7[116] & Ns7[114]) ^ (Ns7[110] & Ns7[109])
          ^ (Ns7[100] & Ns7[68])  ^ (Ns7[87]  & Ns7[79])  ^ (Ns7[66]  & Ns7[62])
          ^ (Ns7[59]  & Ns7[43]);
assign N_next = {Ns7[126:0], Nfb7};   // S_8 — what NFSR register loads next clock

// ----------------------------------------------------------------
// 8 Parallel Keystream Bits using Grain-128 h function
// h = (x0.x1)^(x2.x3)^(x4.x5)^(x6.x7)^(x0.x4.x8)
// x0=Ls[124], x1=Ls[102], x2=Ls[81], x3=Ls[63], x4=Ls[57]
// x5=Ns[118], x6=Ns[87],  x7=Ns[79], x8=Ns[39]
// Z = h ^ Ls[34] ^ Ns[125]^Ns[112]^Ns[91]^Ns[82]^Ns[63]^Ns[54]^Ns[38]
// ----------------------------------------------------------------

// Z[7] — state S_0 (L, N)
wire h7 = (L[124]&L[102])^(L[81]&L[63])^(L[57]&N[118])^(N[87]&N[79])^(L[124]&L[57]&N[39]);
assign Z[7] = h7 ^ L[34] ^ N[125]^N[112]^N[91]^N[82]^N[63]^N[54]^N[38];

// Z[6] — state S_1 (Ls1, Ns1)
wire h6 = (Ls1[124]&Ls1[102])^(Ls1[81]&Ls1[63])^(Ls1[57]&Ns1[118])^(Ns1[87]&Ns1[79])^(Ls1[124]&Ls1[57]&Ns1[39]);
assign Z[6] = h6 ^ Ls1[34] ^ Ns1[125]^Ns1[112]^Ns1[91]^Ns1[82]^Ns1[63]^Ns1[54]^Ns1[38];

// Z[5] — state S_2 (Ls2, Ns2)
wire h5 = (Ls2[124]&Ls2[102])^(Ls2[81]&Ls2[63])^(Ls2[57]&Ns2[118])^(Ns2[87]&Ns2[79])^(Ls2[124]&Ls2[57]&Ns2[39]);
assign Z[5] = h5 ^ Ls2[34] ^ Ns2[125]^Ns2[112]^Ns2[91]^Ns2[82]^Ns2[63]^Ns2[54]^Ns2[38];

// Z[4] — state S_3 (Ls3, Ns3)
wire h4 = (Ls3[124]&Ls3[102])^(Ls3[81]&Ls3[63])^(Ls3[57]&Ns3[118])^(Ns3[87]&Ns3[79])^(Ls3[124]&Ls3[57]&Ns3[39]);
assign Z[4] = h4 ^ Ls3[34] ^ Ns3[125]^Ns3[112]^Ns3[91]^Ns3[82]^Ns3[63]^Ns3[54]^Ns3[38];

// Z[3] — state S_4 (Ls4, Ns4)
wire h3 = (Ls4[124]&Ls4[102])^(Ls4[81]&Ls4[63])^(Ls4[57]&Ns4[118])^(Ns4[87]&Ns4[79])^(Ls4[124]&Ls4[57]&Ns4[39]);
assign Z[3] = h3 ^ Ls4[34] ^ Ns4[125]^Ns4[112]^Ns4[91]^Ns4[82]^Ns4[63]^Ns4[54]^Ns4[38];

// Z[2] — state S_5 (Ls5, Ns5)
wire h2 = (Ls5[124]&Ls5[102])^(Ls5[81]&Ls5[63])^(Ls5[57]&Ns5[118])^(Ns5[87]&Ns5[79])^(Ls5[124]&Ls5[57]&Ns5[39]);
assign Z[2] = h2 ^ Ls5[34] ^ Ns5[125]^Ns5[112]^Ns5[91]^Ns5[82]^Ns5[63]^Ns5[54]^Ns5[38];

// Z[1] — state S_6 (Ls6, Ns6)
wire h1 = (Ls6[124]&Ls6[102])^(Ls6[81]&Ls6[63])^(Ls6[57]&Ns6[118])^(Ns6[87]&Ns6[79])^(Ls6[124]&Ls6[57]&Ns6[39]);
assign Z[1] = h1 ^ Ls6[34] ^ Ns6[125]^Ns6[112]^Ns6[91]^Ns6[82]^Ns6[63]^Ns6[54]^Ns6[38];

// Z[0] — state S_7 (Ls7, Ns7)
wire h0 = (Ls7[124]&Ls7[102])^(Ls7[81]&Ls7[63])^(Ls7[57]&Ns7[118])^(Ns7[87]&Ns7[79])^(Ls7[124]&Ls7[57]&Ns7[39]);
assign Z[0] = h0 ^ Ls7[34] ^ Ns7[125]^Ns7[112]^Ns7[91]^Ns7[82]^Ns7[63]^Ns7[54]^Ns7[38];

endmodule
