

module sine_gen(
	input	wire	clk,
	input 	wire 	rst,
	input   wire	send,
	output  wire	[15:0]  s1,
	output  wire	[15:0]  s2
    );

reg [15:0]  q1;
reg [15:0]  q2;
reg [9:0]   ms; // main state

assign s1 = q1;
assign s2 = q2;

localparam
    ms_pause    = 10'd0,
    ms_1        = 10'd1,
    ms_2        = 10'd2,
    ms_3        = 10'd3,
    ms_4        = 10'd4,
    ms_5        = 10'd5,
    ms_6        = 10'd6,
    ms_7        = 10'd7,
    ms_8        = 10'd8,
    ms_9        = 10'd9,
    ms_10        = 10'd10,
    ms_11        = 10'd11,
    ms_12        = 10'd12,
    ms_13        = 10'd13,
    ms_14        = 10'd14,
    ms_15        = 10'd15,
    ms_16        = 10'd16,
    ms_17        = 10'd17,
    ms_18        = 10'd18,
    ms_19        = 10'd19,
    ms_20        = 10'd20,
    ms_21        = 10'd21,
    ms_22        = 10'd22,
    ms_23        = 10'd23,
    ms_24        = 10'd24,
    ms_25        = 10'd25,
    ms_26        = 10'd26,
    ms_27        = 10'd27,
    ms_28        = 10'd28,
    ms_29        = 10'd29,
    ms_30        = 10'd30,
    ms_31        = 10'd31,
    ms_32        = 10'd32,
    ms_33        = 10'd33,
    ms_34        = 10'd34,
    ms_35        = 10'd35,
    ms_36        = 10'd36,
    ms_37        = 10'd37,
    ms_38        = 10'd38,
    ms_39        = 10'd39,
    ms_40        = 10'd40,
    ms_41        = 10'd41,
    ms_42        = 10'd42,
    ms_43        = 10'd43,
    ms_44        = 10'd44,
    ms_45        = 10'd45,
    ms_46        = 10'd46,
    ms_47        = 10'd47,
    ms_48        = 10'd48,
    ms_49        = 10'd49,
    ms_50        = 10'd50,
    ms_51        = 10'd51,
    ms_52        = 10'd52,
    ms_53        = 10'd53,
    ms_54        = 10'd54,
    ms_55        = 10'd55,
    ms_56        = 10'd56,
    ms_57        = 10'd57,
    ms_58        = 10'd58,
    ms_59        = 10'd59,
    ms_60        = 10'd60,
    ms_61        = 10'd61,
    ms_62        = 10'd62,
    ms_63        = 10'd63,
    ms_64        = 10'd64,
    ms_65        = 10'd65,
    ms_66        = 10'd66,
    ms_67        = 10'd67,
    ms_68        = 10'd68,
    ms_69        = 10'd69,
    ms_70        = 10'd70,
    ms_71        = 10'd71,
    ms_72        = 10'd72,
    ms_73        = 10'd73,
    ms_74        = 10'd74,
    ms_75        = 10'd75,
    ms_76        = 10'd76,
    ms_77        = 10'd77,
    ms_78        = 10'd78,
    ms_79        = 10'd79,
    ms_80        = 10'd80,
    ms_81        = 10'd81,
    ms_82        = 10'd82,
    ms_83        = 10'd83,
    ms_84        = 10'd84,
    ms_85        = 10'd85,
    ms_86        = 10'd86,
    ms_87        = 10'd87,
    ms_88        = 10'd88,
    ms_89        = 10'd89,
    ms_90        = 10'd90,
    ms_91        = 10'd91,
    ms_92        = 10'd92,
    ms_93        = 10'd93,
    ms_94        = 10'd94,
    ms_95        = 10'd95,
    ms_96        = 10'd96,
    ms_97        = 10'd97,
    ms_98        = 10'd98,
    ms_99        = 10'd99,
    ms_100        = 10'd100,
    ms_101        = 10'd101,
    ms_102        = 10'd102,
    ms_103        = 10'd103,
    ms_104        = 10'd104,
    ms_105        = 10'd105,
    ms_106        = 10'd106,
    ms_107        = 10'd107,
    ms_108        = 10'd108,
    ms_109        = 10'd109,
    ms_110        = 10'd110,
    ms_111        = 10'd111,
    ms_112        = 10'd112,
    ms_113        = 10'd113,
    ms_114        = 10'd114,
    ms_115        = 10'd115,
    ms_116        = 10'd116,
    ms_117        = 10'd117,
    ms_118        = 10'd118,
    ms_119        = 10'd119,
    ms_120        = 10'd120,
    ms_121        = 10'd121,
    ms_122        = 10'd122,
    ms_123        = 10'd123,
    ms_124        = 10'd124,
    ms_125        = 10'd125,
    ms_126        = 10'd126,
    ms_127        = 10'd127,
    ms_128        = 10'd128,
    ms_129        = 10'd129,
    ms_130        = 10'd130,
    ms_131        = 10'd131,
    ms_132        = 10'd132,
    ms_133        = 10'd133,
    ms_134        = 10'd134,
    ms_135        = 10'd135,
    ms_136        = 10'd136,
    ms_137        = 10'd137,
    ms_138        = 10'd138,
    ms_139        = 10'd139,
    ms_140        = 10'd140,
    ms_141        = 10'd141,
    ms_142        = 10'd142,
    ms_143        = 10'd143,
    ms_144        = 10'd144,
    ms_145        = 10'd145,
    ms_146        = 10'd146,
    ms_147        = 10'd147,
    ms_148        = 10'd148,
    ms_149        = 10'd149,
    ms_150        = 10'd150,
    ms_151        = 10'd151,
    ms_152        = 10'd152,
    ms_153        = 10'd153,
    ms_154        = 10'd154,
    ms_155        = 10'd155,
    ms_156        = 10'd156,
    ms_157        = 10'd157,
    ms_158        = 10'd158,
    ms_159        = 10'd159,
    ms_160        = 10'd160;

initial begin
	q1 <= 16'h8000;
	q2 <= 16'h8000;
	ms <= ms_pause;
end

always @(posedge rst or posedge clk) begin
	if (rst) begin
		q1 <= 16'h8000;
		q2 <= 16'h8000;
		ms <= ms_pause;
	end else begin
	    case (ms) 
		ms_pause: begin
		    q1 <= 16'h8000;
		    q2 <= 16'h8000;
		    if (send) begin
		        ms <= ms_1;
		    end else begin
		        ms <= ms_pause;
		    end
		end
		ms_1: begin
		    q1 <= 16'h8000;
		    q2 <= 16'h800d;
		    ms <= ms_2;
		end
		ms_2: begin
		    q1 <= 16'h801a;
		    q2 <= 16'h8027;
		    ms <= ms_3;
		end
		ms_3: begin
		    q1 <= 16'h8033;
		    q2 <= 16'h8040;
		    ms <= ms_4;
		end
		ms_4: begin
		    q1 <= 16'h804c;
		    q2 <= 16'h8059;
		    ms <= ms_5;
		end
		ms_5: begin
		    q1 <= 16'h8065;
		    q2 <= 16'h8071;
		    ms <= ms_6;
		end
		ms_6: begin
		    q1 <= 16'h807d;
		    q2 <= 16'h8089;
		    ms <= ms_7;
		end
		ms_7: begin
		    q1 <= 16'h8095;
		    q2 <= 16'h80a0;
		    ms <= ms_8;
		end
		ms_8: begin
		    q1 <= 16'h80ab;
		    q2 <= 16'h80b6;
		    ms <= ms_9;
		end
		ms_9: begin
		    q1 <= 16'h80c1;
		    q2 <= 16'h80cb;
		    ms <= ms_10;
		end
		ms_10: begin
		    q1 <= 16'h80d5;
		    q2 <= 16'h80de;
		    ms <= ms_11;
		end
		ms_11: begin
		    q1 <= 16'h80e8;
		    q2 <= 16'h80f1;
		    ms <= ms_12;
		end
		ms_12: begin
		    q1 <= 16'h80f9;
		    q2 <= 16'h8101;
		    ms <= ms_13;
		end
		ms_13: begin
		    q1 <= 16'h8109;
		    q2 <= 16'h8110;
		    ms <= ms_14;
		end
		ms_14: begin
		    q1 <= 16'h8117;
		    q2 <= 16'h811e;
		    ms <= ms_15;
		end
		ms_15: begin
		    q1 <= 16'h8124;
		    q2 <= 16'h812a;
		    ms <= ms_16;
		end
		ms_16: begin
		    q1 <= 16'h812f;
		    q2 <= 16'h8133;
		    ms <= ms_17;
		end
		ms_17: begin
		    q1 <= 16'h8138;
		    q2 <= 16'h813b;
		    ms <= ms_18;
		end
		ms_18: begin
		    q1 <= 16'h813f;
		    q2 <= 16'h8141;
		    ms <= ms_19;
		end
		ms_19: begin
		    q1 <= 16'h8144;
		    q2 <= 16'h8145;
		    ms <= ms_20;
		end
		ms_20: begin
		    q1 <= 16'h8147;
		    q2 <= 16'h8147;
		    ms <= ms_21;
		end
		ms_21: begin
		    q1 <= 16'h8148;
		    q2 <= 16'h8147;
		    ms <= ms_22;
		end
		ms_22: begin
		    q1 <= 16'h8147;
		    q2 <= 16'h8145;
		    ms <= ms_23;
		end
		ms_23: begin
		    q1 <= 16'h8144;
		    q2 <= 16'h8141;
		    ms <= ms_24;
		end
		ms_24: begin
		    q1 <= 16'h813f;
		    q2 <= 16'h813b;
		    ms <= ms_25;
		end
		ms_25: begin
		    q1 <= 16'h8138;
		    q2 <= 16'h8133;
		    ms <= ms_26;
		end
		ms_26: begin
		    q1 <= 16'h812f;
		    q2 <= 16'h812a;
		    ms <= ms_27;
		end
		ms_27: begin
		    q1 <= 16'h8124;
		    q2 <= 16'h811e;
		    ms <= ms_28;
		end
		ms_28: begin
		    q1 <= 16'h8117;
		    q2 <= 16'h8110;
		    ms <= ms_29;
		end
		ms_29: begin
		    q1 <= 16'h8109;
		    q2 <= 16'h8101;
		    ms <= ms_30;
		end
		ms_30: begin
		    q1 <= 16'h80f9;
		    q2 <= 16'h80f1;
		    ms <= ms_31;
		end
		ms_31: begin
		    q1 <= 16'h80e8;
		    q2 <= 16'h80de;
		    ms <= ms_32;
		end
		ms_32: begin
		    q1 <= 16'h80d5;
		    q2 <= 16'h80cb;
		    ms <= ms_33;
		end
		ms_33: begin
		    q1 <= 16'h80c1;
		    q2 <= 16'h80b6;
		    ms <= ms_34;
		end
		ms_34: begin
		    q1 <= 16'h80ab;
		    q2 <= 16'h80a0;
		    ms <= ms_35;
		end
		ms_35: begin
		    q1 <= 16'h8095;
		    q2 <= 16'h8089;
		    ms <= ms_36;
		end
		ms_36: begin
		    q1 <= 16'h807d;
		    q2 <= 16'h8071;
		    ms <= ms_37;
		end
		ms_37: begin
		    q1 <= 16'h8065;
		    q2 <= 16'h8059;
		    ms <= ms_38;
		end
		ms_38: begin
		    q1 <= 16'h804c;
		    q2 <= 16'h8040;
		    ms <= ms_39;
		end
		ms_39: begin
		    q1 <= 16'h8033;
		    q2 <= 16'h8027;
		    ms <= ms_40;
		end
		ms_40: begin
		    q1 <= 16'h801a;
		    q2 <= 16'h800d;
		    ms <= ms_41;
		end
		ms_41: begin
		    q1 <= 16'h8000;
		    q2 <= 16'h7ff3;
		    ms <= ms_42;
		end
		ms_42: begin
		    q1 <= 16'h7fe6;
		    q2 <= 16'h7fd9;
		    ms <= ms_43;
		end
		ms_43: begin
		    q1 <= 16'h7fcd;
		    q2 <= 16'h7fc0;
		    ms <= ms_44;
		end
		ms_44: begin
		    q1 <= 16'h7fb4;
		    q2 <= 16'h7fa7;
		    ms <= ms_45;
		end
		ms_45: begin
		    q1 <= 16'h7f9b;
		    q2 <= 16'h7f8f;
		    ms <= ms_46;
		end
		ms_46: begin
		    q1 <= 16'h7f83;
		    q2 <= 16'h7f77;
		    ms <= ms_47;
		end
		ms_47: begin
		    q1 <= 16'h7f6b;
		    q2 <= 16'h7f60;
		    ms <= ms_48;
		end
		ms_48: begin
		    q1 <= 16'h7f55;
		    q2 <= 16'h7f4a;
		    ms <= ms_49;
		end
		ms_49: begin
		    q1 <= 16'h7f3f;
		    q2 <= 16'h7f35;
		    ms <= ms_50;
		end
		ms_50: begin
		    q1 <= 16'h7f2b;
		    q2 <= 16'h7f22;
		    ms <= ms_51;
		end
		ms_51: begin
		    q1 <= 16'h7f18;
		    q2 <= 16'h7f0f;
		    ms <= ms_52;
		end
		ms_52: begin
		    q1 <= 16'h7f07;
		    q2 <= 16'h7eff;
		    ms <= ms_53;
		end
		ms_53: begin
		    q1 <= 16'h7ef7;
		    q2 <= 16'h7ef0;
		    ms <= ms_54;
		end
		ms_54: begin
		    q1 <= 16'h7ee9;
		    q2 <= 16'h7ee2;
		    ms <= ms_55;
		end
		ms_55: begin
		    q1 <= 16'h7edc;
		    q2 <= 16'h7ed6;
		    ms <= ms_56;
		end
		ms_56: begin
		    q1 <= 16'h7ed1;
		    q2 <= 16'h7ecd;
		    ms <= ms_57;
		end
		ms_57: begin
		    q1 <= 16'h7ec8;
		    q2 <= 16'h7ec5;
		    ms <= ms_58;
		end
		ms_58: begin
		    q1 <= 16'h7ec1;
		    q2 <= 16'h7ebf;
		    ms <= ms_59;
		end
		ms_59: begin
		    q1 <= 16'h7ebc;
		    q2 <= 16'h7ebb;
		    ms <= ms_60;
		end
		ms_60: begin
		    q1 <= 16'h7eb9;
		    q2 <= 16'h7eb9;
		    ms <= ms_61;
		end
		ms_61: begin
		    q1 <= 16'h7eb8;
		    q2 <= 16'h7eb9;
		    ms <= ms_62;
		end
		ms_62: begin
		    q1 <= 16'h7eb9;
		    q2 <= 16'h7ebb;
		    ms <= ms_63;
		end
		ms_63: begin
		    q1 <= 16'h7ebc;
		    q2 <= 16'h7ebf;
		    ms <= ms_64;
		end
		ms_64: begin
		    q1 <= 16'h7ec1;
		    q2 <= 16'h7ec5;
		    ms <= ms_65;
		end
		ms_65: begin
		    q1 <= 16'h7ec8;
		    q2 <= 16'h7ecd;
		    ms <= ms_66;
		end
		ms_66: begin
		    q1 <= 16'h7ed1;
		    q2 <= 16'h7ed6;
		    ms <= ms_67;
		end
		ms_67: begin
		    q1 <= 16'h7edc;
		    q2 <= 16'h7ee2;
		    ms <= ms_68;
		end
		ms_68: begin
		    q1 <= 16'h7ee9;
		    q2 <= 16'h7ef0;
		    ms <= ms_69;
		end
		ms_69: begin
		    q1 <= 16'h7ef7;
		    q2 <= 16'h7eff;
		    ms <= ms_70;
		end
		ms_70: begin
		    q1 <= 16'h7f07;
		    q2 <= 16'h7f0f;
		    ms <= ms_71;
		end
		ms_71: begin
		    q1 <= 16'h7f18;
		    q2 <= 16'h7f22;
		    ms <= ms_72;
		end
		ms_72: begin
		    q1 <= 16'h7f2b;
		    q2 <= 16'h7f35;
		    ms <= ms_73;
		end
		ms_73: begin
		    q1 <= 16'h7f3f;
		    q2 <= 16'h7f4a;
		    ms <= ms_74;
		end
		ms_74: begin
		    q1 <= 16'h7f55;
		    q2 <= 16'h7f60;
		    ms <= ms_75;
		end
		ms_75: begin
		    q1 <= 16'h7f6b;
		    q2 <= 16'h7f77;
		    ms <= ms_76;
		end
		ms_76: begin
		    q1 <= 16'h7f83;
		    q2 <= 16'h7f8f;
		    ms <= ms_77;
		end
		ms_77: begin
		    q1 <= 16'h7f9b;
		    q2 <= 16'h7fa7;
		    ms <= ms_78;
		end
		ms_78: begin
		    q1 <= 16'h7fb4;
		    q2 <= 16'h7fc0;
		    ms <= ms_79;
		end
		ms_79: begin
		    q1 <= 16'h7fcd;
		    q2 <= 16'h7fd9;
		    ms <= ms_80;
		end
		ms_80: begin
		    q1 <= 16'h7fe6;
		    q2 <= 16'h7ff3;
		    if (send) begin
				ms <= ms_1;
		    end else begin
		        ms <= ms_pause;
		    end
		end
		default: begin
		    q1 <= 16'h8000;
		    q2 <= 16'h8000;
		    ms <= ms_pause;
		end
	    endcase
	end
end

endmodule
