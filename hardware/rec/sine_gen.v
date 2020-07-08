

module sine_gen(
	input	wire	clk,
	input 	wire 	rst,
	input   wire	send,
	output  wire	[15:0]  sine
    );

reg [15:0]  q;
reg [9:0]   ms; // main state

assign sine = q;

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
    ms_160        = 10'd160,
    ms_161        = 10'd161,
    ms_162        = 10'd162,
    ms_163        = 10'd163,
    ms_164        = 10'd164,
    ms_165        = 10'd165,
    ms_166        = 10'd166,
    ms_167        = 10'd167,
    ms_168        = 10'd168,
    ms_169        = 10'd169,
    ms_170        = 10'd170,
    ms_171        = 10'd171,
    ms_172        = 10'd172,
    ms_173        = 10'd173,
    ms_174        = 10'd174,
    ms_175        = 10'd175,
    ms_176        = 10'd176,
    ms_177        = 10'd177,
    ms_178        = 10'd178,
    ms_179        = 10'd179,
    ms_180        = 10'd180,
    ms_181        = 10'd181,
    ms_182        = 10'd182,
    ms_183        = 10'd183,
    ms_184        = 10'd184,
    ms_185        = 10'd185,
    ms_186        = 10'd186,
    ms_187        = 10'd187,
    ms_188        = 10'd188,
    ms_189        = 10'd189,
    ms_190        = 10'd190,
    ms_191        = 10'd191,
    ms_192        = 10'd192,
    ms_193        = 10'd193,
    ms_194        = 10'd194,
    ms_195        = 10'd195,
    ms_196        = 10'd196,
    ms_197        = 10'd197,
    ms_198        = 10'd198,
    ms_199        = 10'd199,
    ms_200        = 10'd200,
    ms_201        = 10'd201,
    ms_202        = 10'd202,
    ms_203        = 10'd203,
    ms_204        = 10'd204,
    ms_205        = 10'd205,
    ms_206        = 10'd206,
    ms_207        = 10'd207,
    ms_208        = 10'd208,
    ms_209        = 10'd209,
    ms_210        = 10'd210,
    ms_211        = 10'd211,
    ms_212        = 10'd212,
    ms_213        = 10'd213,
    ms_214        = 10'd214,
    ms_215        = 10'd215,
    ms_216        = 10'd216,
    ms_217        = 10'd217,
    ms_218        = 10'd218,
    ms_219        = 10'd219,
    ms_220        = 10'd220,
    ms_221        = 10'd221,
    ms_222        = 10'd222,
    ms_223        = 10'd223,
    ms_224        = 10'd224,
    ms_225        = 10'd225,
    ms_226        = 10'd226,
    ms_227        = 10'd227,
    ms_228        = 10'd228,
    ms_229        = 10'd229,
    ms_230        = 10'd230,
    ms_231        = 10'd231,
    ms_232        = 10'd232,
    ms_233        = 10'd233,
    ms_234        = 10'd234,
    ms_235        = 10'd235,
    ms_236        = 10'd236,
    ms_237        = 10'd237,
    ms_238        = 10'd238,
    ms_239        = 10'd239,
    ms_240        = 10'd240,
    ms_241        = 10'd241,
    ms_242        = 10'd242,
    ms_243        = 10'd243,
    ms_244        = 10'd244,
    ms_245        = 10'd245,
    ms_246        = 10'd246,
    ms_247        = 10'd247,
    ms_248        = 10'd248,
    ms_249        = 10'd249,
    ms_250        = 10'd250,
    ms_251        = 10'd251,
    ms_252        = 10'd252,
    ms_253        = 10'd253,
    ms_254        = 10'd254,
    ms_255        = 10'd255,
    ms_256        = 10'd256,
    ms_257        = 10'd257,
    ms_258        = 10'd258,
    ms_259        = 10'd259,
    ms_260        = 10'd260,
    ms_261        = 10'd261,
    ms_262        = 10'd262,
    ms_263        = 10'd263,
    ms_264        = 10'd264,
    ms_265        = 10'd265,
    ms_266        = 10'd266,
    ms_267        = 10'd267,
    ms_268        = 10'd268,
    ms_269        = 10'd269,
    ms_270        = 10'd270,
    ms_271        = 10'd271,
    ms_272        = 10'd272,
    ms_273        = 10'd273,
    ms_274        = 10'd274,
    ms_275        = 10'd275,
    ms_276        = 10'd276,
    ms_277        = 10'd277,
    ms_278        = 10'd278,
    ms_279        = 10'd279,
    ms_280        = 10'd280,
    ms_281        = 10'd281,
    ms_282        = 10'd282,
    ms_283        = 10'd283,
    ms_284        = 10'd284,
    ms_285        = 10'd285,
    ms_286        = 10'd286,
    ms_287        = 10'd287,
    ms_288        = 10'd288,
    ms_289        = 10'd289,
    ms_290        = 10'd290,
    ms_291        = 10'd291,
    ms_292        = 10'd292,
    ms_293        = 10'd293,
    ms_294        = 10'd294,
    ms_295        = 10'd295,
    ms_296        = 10'd296,
    ms_297        = 10'd297,
    ms_298        = 10'd298,
    ms_299        = 10'd299,
    ms_300        = 10'd300,
    ms_301        = 10'd301,
    ms_302        = 10'd302,
    ms_303        = 10'd303,
    ms_304        = 10'd304,
    ms_305        = 10'd305,
    ms_306        = 10'd306,
    ms_307        = 10'd307,
    ms_308        = 10'd308,
    ms_309        = 10'd309,
    ms_310        = 10'd310,
    ms_311        = 10'd311,
    ms_312        = 10'd312,
    ms_313        = 10'd313,
    ms_314        = 10'd314,
    ms_315        = 10'd315,
    ms_316        = 10'd316,
    ms_317        = 10'd317,
    ms_318        = 10'd318,
    ms_319        = 10'd319,
    ms_320        = 10'd320,
    ms_321        = 10'd321,
    ms_322        = 10'd322,
    ms_323        = 10'd323,
    ms_324        = 10'd324,
    ms_325        = 10'd325,
    ms_326        = 10'd326,
    ms_327        = 10'd327,
    ms_328        = 10'd328,
    ms_329        = 10'd329,
    ms_330        = 10'd330,
    ms_331        = 10'd331,
    ms_332        = 10'd332,
    ms_333        = 10'd333,
    ms_334        = 10'd334,
    ms_335        = 10'd335,
    ms_336        = 10'd336,
    ms_337        = 10'd337,
    ms_338        = 10'd338,
    ms_339        = 10'd339,
    ms_340        = 10'd340,
    ms_341        = 10'd341,
    ms_342        = 10'd342,
    ms_343        = 10'd343,
    ms_344        = 10'd344,
    ms_345        = 10'd345,
    ms_346        = 10'd346,
    ms_347        = 10'd347,
    ms_348        = 10'd348,
    ms_349        = 10'd349,
    ms_350        = 10'd350,
    ms_351        = 10'd351,
    ms_352        = 10'd352,
    ms_353        = 10'd353,
    ms_354        = 10'd354,
    ms_355        = 10'd355,
    ms_356        = 10'd356,
    ms_357        = 10'd357,
    ms_358        = 10'd358,
    ms_359        = 10'd359,
    ms_360        = 10'd360,
    ms_361        = 10'd361,
    ms_362        = 10'd362,
    ms_363        = 10'd363,
    ms_364        = 10'd364,
    ms_365        = 10'd365,
    ms_366        = 10'd366,
    ms_367        = 10'd367,
    ms_368        = 10'd368,
    ms_369        = 10'd369,
    ms_370        = 10'd370,
    ms_371        = 10'd371,
    ms_372        = 10'd372,
    ms_373        = 10'd373,
    ms_374        = 10'd374,
    ms_375        = 10'd375,
    ms_376        = 10'd376,
    ms_377        = 10'd377,
    ms_378        = 10'd378,
    ms_379        = 10'd379,
    ms_380        = 10'd380,
    ms_381        = 10'd381,
    ms_382        = 10'd382,
    ms_383        = 10'd383,
    ms_384        = 10'd384,
    ms_385        = 10'd385,
    ms_386        = 10'd386,
    ms_387        = 10'd387,
    ms_388        = 10'd388,
    ms_389        = 10'd389,
    ms_390        = 10'd390,
    ms_391        = 10'd391,
    ms_392        = 10'd392,
    ms_393        = 10'd393,
    ms_394        = 10'd394,
    ms_395        = 10'd395,
    ms_396        = 10'd396,
    ms_397        = 10'd397,
    ms_398        = 10'd398,
    ms_399        = 10'd399,
    ms_400        = 10'd400;

initial begin
	q <= 16'h8000;
	ms <= ms_pause;
end

always @(posedge rst or posedge clk) begin
	if (rst) begin
		q <= 16'h8000;
		ms <= ms_pause;
	end else begin
	    case (ms) 
		ms_pause: begin
		    q <= 16'h8000;
		    if (send) begin
		        ms <= ms_1;
		    end else begin
		        ms <= ms_pause;
		    end
		end
		ms_1: begin
		    q <= 16'h8000;
		    ms <= ms_2;
		end
		ms_2: begin
		    q <= 16'h8101;
		    ms <= ms_3;
		end
		ms_3: begin
		    q <= 16'h8203;
		    ms <= ms_4;
		end
		ms_4: begin
		    q <= 16'h8304;
		    ms <= ms_5;
		end
		ms_5: begin
		    q <= 16'h8405;
		    ms <= ms_6;
		end
		ms_6: begin
		    q <= 16'h8505;
		    ms <= ms_7;
		end
		ms_7: begin
		    q <= 16'h8606;
		    ms <= ms_8;
		end
		ms_8: begin
		    q <= 16'h8706;
		    ms <= ms_9;
		end
		ms_9: begin
		    q <= 16'h8805;
		    ms <= ms_10;
		end
		ms_10: begin
		    q <= 16'h8905;
		    ms <= ms_11;
		end
		ms_11: begin
		    q <= 16'h8a03;
		    ms <= ms_12;
		end
		ms_12: begin
		    q <= 16'h8b01;
		    ms <= ms_13;
		end
		ms_13: begin
		    q <= 16'h8bfe;
		    ms <= ms_14;
		end
		ms_14: begin
		    q <= 16'h8cfa;
		    ms <= ms_15;
		end
		ms_15: begin
		    q <= 16'h8df6;
		    ms <= ms_16;
		end
		ms_16: begin
		    q <= 16'h8ef1;
		    ms <= ms_17;
		end
		ms_17: begin
		    q <= 16'h8feb;
		    ms <= ms_18;
		end
		ms_18: begin
		    q <= 16'h90e3;
		    ms <= ms_19;
		end
		ms_19: begin
		    q <= 16'h91db;
		    ms <= ms_20;
		end
		ms_20: begin
		    q <= 16'h92d2;
		    ms <= ms_21;
		end
		ms_21: begin
		    q <= 16'h93c7;
		    ms <= ms_22;
		end
		ms_22: begin
		    q <= 16'h94bb;
		    ms <= ms_23;
		end
		ms_23: begin
		    q <= 16'h95ae;
		    ms <= ms_24;
		end
		ms_24: begin
		    q <= 16'h969f;
		    ms <= ms_25;
		end
		ms_25: begin
		    q <= 16'h978f;
		    ms <= ms_26;
		end
		ms_26: begin
		    q <= 16'h987e;
		    ms <= ms_27;
		end
		ms_27: begin
		    q <= 16'h996b;
		    ms <= ms_28;
		end
		ms_28: begin
		    q <= 16'h9a56;
		    ms <= ms_29;
		end
		ms_29: begin
		    q <= 16'h9b40;
		    ms <= ms_30;
		end
		ms_30: begin
		    q <= 16'h9c28;
		    ms <= ms_31;
		end
		ms_31: begin
		    q <= 16'h9d0e;
		    ms <= ms_32;
		end
		ms_32: begin
		    q <= 16'h9df3;
		    ms <= ms_33;
		end
		ms_33: begin
		    q <= 16'h9ed5;
		    ms <= ms_34;
		end
		ms_34: begin
		    q <= 16'h9fb6;
		    ms <= ms_35;
		end
		ms_35: begin
		    q <= 16'ha094;
		    ms <= ms_36;
		end
		ms_36: begin
		    q <= 16'ha171;
		    ms <= ms_37;
		end
		ms_37: begin
		    q <= 16'ha24b;
		    ms <= ms_38;
		end
		ms_38: begin
		    q <= 16'ha323;
		    ms <= ms_39;
		end
		ms_39: begin
		    q <= 16'ha3f9;
		    ms <= ms_40;
		end
		ms_40: begin
		    q <= 16'ha4cd;
		    ms <= ms_41;
		end
		ms_41: begin
		    q <= 16'ha59e;
		    ms <= ms_42;
		end
		ms_42: begin
		    q <= 16'ha66d;
		    ms <= ms_43;
		end
		ms_43: begin
		    q <= 16'ha73a;
		    ms <= ms_44;
		end
		ms_44: begin
		    q <= 16'ha804;
		    ms <= ms_45;
		end
		ms_45: begin
		    q <= 16'ha8cc;
		    ms <= ms_46;
		end
		ms_46: begin
		    q <= 16'ha991;
		    ms <= ms_47;
		end
		ms_47: begin
		    q <= 16'haa53;
		    ms <= ms_48;
		end
		ms_48: begin
		    q <= 16'hab13;
		    ms <= ms_49;
		end
		ms_49: begin
		    q <= 16'habd0;
		    ms <= ms_50;
		end
		ms_50: begin
		    q <= 16'hac8a;
		    ms <= ms_51;
		end
		ms_51: begin
		    q <= 16'had41;
		    ms <= ms_52;
		end
		ms_52: begin
		    q <= 16'hadf6;
		    ms <= ms_53;
		end
		ms_53: begin
		    q <= 16'haea7;
		    ms <= ms_54;
		end
		ms_54: begin
		    q <= 16'haf56;
		    ms <= ms_55;
		end
		ms_55: begin
		    q <= 16'hb002;
		    ms <= ms_56;
		end
		ms_56: begin
		    q <= 16'hb0aa;
		    ms <= ms_57;
		end
		ms_57: begin
		    q <= 16'hb150;
		    ms <= ms_58;
		end
		ms_58: begin
		    q <= 16'hb1f3;
		    ms <= ms_59;
		end
		ms_59: begin
		    q <= 16'hb292;
		    ms <= ms_60;
		end
		ms_60: begin
		    q <= 16'hb32e;
		    ms <= ms_61;
		end
		ms_61: begin
		    q <= 16'hb3c7;
		    ms <= ms_62;
		end
		ms_62: begin
		    q <= 16'hb45d;
		    ms <= ms_63;
		end
		ms_63: begin
		    q <= 16'hb4ef;
		    ms <= ms_64;
		end
		ms_64: begin
		    q <= 16'hb57e;
		    ms <= ms_65;
		end
		ms_65: begin
		    q <= 16'hb609;
		    ms <= ms_66;
		end
		ms_66: begin
		    q <= 16'hb692;
		    ms <= ms_67;
		end
		ms_67: begin
		    q <= 16'hb716;
		    ms <= ms_68;
		end
		ms_68: begin
		    q <= 16'hb798;
		    ms <= ms_69;
		end
		ms_69: begin
		    q <= 16'hb815;
		    ms <= ms_70;
		end
		ms_70: begin
		    q <= 16'hb890;
		    ms <= ms_71;
		end
		ms_71: begin
		    q <= 16'hb906;
		    ms <= ms_72;
		end
		ms_72: begin
		    q <= 16'hb979;
		    ms <= ms_73;
		end
		ms_73: begin
		    q <= 16'hb9e9;
		    ms <= ms_74;
		end
		ms_74: begin
		    q <= 16'hba54;
		    ms <= ms_75;
		end
		ms_75: begin
		    q <= 16'hbabc;
		    ms <= ms_76;
		end
		ms_76: begin
		    q <= 16'hbb21;
		    ms <= ms_77;
		end
		ms_77: begin
		    q <= 16'hbb81;
		    ms <= ms_78;
		end
		ms_78: begin
		    q <= 16'hbbde;
		    ms <= ms_79;
		end
		ms_79: begin
		    q <= 16'hbc37;
		    ms <= ms_80;
		end
		ms_80: begin
		    q <= 16'hbc8d;
		    ms <= ms_81;
		end
		ms_81: begin
		    q <= 16'hbcde;
		    ms <= ms_82;
		end
		ms_82: begin
		    q <= 16'hbd2c;
		    ms <= ms_83;
		end
		ms_83: begin
		    q <= 16'hbd75;
		    ms <= ms_84;
		end
		ms_84: begin
		    q <= 16'hbdbb;
		    ms <= ms_85;
		end
		ms_85: begin
		    q <= 16'hbdfd;
		    ms <= ms_86;
		end
		ms_86: begin
		    q <= 16'hbe3b;
		    ms <= ms_87;
		end
		ms_87: begin
		    q <= 16'hbe75;
		    ms <= ms_88;
		end
		ms_88: begin
		    q <= 16'hbeac;
		    ms <= ms_89;
		end
		ms_89: begin
		    q <= 16'hbede;
		    ms <= ms_90;
		end
		ms_90: begin
		    q <= 16'hbf0c;
		    ms <= ms_91;
		end
		ms_91: begin
		    q <= 16'hbf36;
		    ms <= ms_92;
		end
		ms_92: begin
		    q <= 16'hbf5d;
		    ms <= ms_93;
		end
		ms_93: begin
		    q <= 16'hbf7f;
		    ms <= ms_94;
		end
		ms_94: begin
		    q <= 16'hbf9d;
		    ms <= ms_95;
		end
		ms_95: begin
		    q <= 16'hbfb7;
		    ms <= ms_96;
		end
		ms_96: begin
		    q <= 16'hbfcd;
		    ms <= ms_97;
		end
		ms_97: begin
		    q <= 16'hbfe0;
		    ms <= ms_98;
		end
		ms_98: begin
		    q <= 16'hbfee;
		    ms <= ms_99;
		end
		ms_99: begin
		    q <= 16'hbff8;
		    ms <= ms_100;
		end
		ms_100: begin
		    q <= 16'hbffe;
		    ms <= ms_101;
		end
		ms_101: begin
		    q <= 16'hc000;
		    ms <= ms_102;
		end
		ms_102: begin
		    q <= 16'hbffe;
		    ms <= ms_103;
		end
		ms_103: begin
		    q <= 16'hbff8;
		    ms <= ms_104;
		end
		ms_104: begin
		    q <= 16'hbfee;
		    ms <= ms_105;
		end
		ms_105: begin
		    q <= 16'hbfe0;
		    ms <= ms_106;
		end
		ms_106: begin
		    q <= 16'hbfcd;
		    ms <= ms_107;
		end
		ms_107: begin
		    q <= 16'hbfb7;
		    ms <= ms_108;
		end
		ms_108: begin
		    q <= 16'hbf9d;
		    ms <= ms_109;
		end
		ms_109: begin
		    q <= 16'hbf7f;
		    ms <= ms_110;
		end
		ms_110: begin
		    q <= 16'hbf5d;
		    ms <= ms_111;
		end
		ms_111: begin
		    q <= 16'hbf36;
		    ms <= ms_112;
		end
		ms_112: begin
		    q <= 16'hbf0c;
		    ms <= ms_113;
		end
		ms_113: begin
		    q <= 16'hbede;
		    ms <= ms_114;
		end
		ms_114: begin
		    q <= 16'hbeac;
		    ms <= ms_115;
		end
		ms_115: begin
		    q <= 16'hbe75;
		    ms <= ms_116;
		end
		ms_116: begin
		    q <= 16'hbe3b;
		    ms <= ms_117;
		end
		ms_117: begin
		    q <= 16'hbdfd;
		    ms <= ms_118;
		end
		ms_118: begin
		    q <= 16'hbdbb;
		    ms <= ms_119;
		end
		ms_119: begin
		    q <= 16'hbd75;
		    ms <= ms_120;
		end
		ms_120: begin
		    q <= 16'hbd2c;
		    ms <= ms_121;
		end
		ms_121: begin
		    q <= 16'hbcde;
		    ms <= ms_122;
		end
		ms_122: begin
		    q <= 16'hbc8d;
		    ms <= ms_123;
		end
		ms_123: begin
		    q <= 16'hbc37;
		    ms <= ms_124;
		end
		ms_124: begin
		    q <= 16'hbbde;
		    ms <= ms_125;
		end
		ms_125: begin
		    q <= 16'hbb81;
		    ms <= ms_126;
		end
		ms_126: begin
		    q <= 16'hbb21;
		    ms <= ms_127;
		end
		ms_127: begin
		    q <= 16'hbabc;
		    ms <= ms_128;
		end
		ms_128: begin
		    q <= 16'hba54;
		    ms <= ms_129;
		end
		ms_129: begin
		    q <= 16'hb9e9;
		    ms <= ms_130;
		end
		ms_130: begin
		    q <= 16'hb979;
		    ms <= ms_131;
		end
		ms_131: begin
		    q <= 16'hb906;
		    ms <= ms_132;
		end
		ms_132: begin
		    q <= 16'hb890;
		    ms <= ms_133;
		end
		ms_133: begin
		    q <= 16'hb815;
		    ms <= ms_134;
		end
		ms_134: begin
		    q <= 16'hb798;
		    ms <= ms_135;
		end
		ms_135: begin
		    q <= 16'hb716;
		    ms <= ms_136;
		end
		ms_136: begin
		    q <= 16'hb692;
		    ms <= ms_137;
		end
		ms_137: begin
		    q <= 16'hb609;
		    ms <= ms_138;
		end
		ms_138: begin
		    q <= 16'hb57e;
		    ms <= ms_139;
		end
		ms_139: begin
		    q <= 16'hb4ef;
		    ms <= ms_140;
		end
		ms_140: begin
		    q <= 16'hb45d;
		    ms <= ms_141;
		end
		ms_141: begin
		    q <= 16'hb3c7;
		    ms <= ms_142;
		end
		ms_142: begin
		    q <= 16'hb32e;
		    ms <= ms_143;
		end
		ms_143: begin
		    q <= 16'hb292;
		    ms <= ms_144;
		end
		ms_144: begin
		    q <= 16'hb1f3;
		    ms <= ms_145;
		end
		ms_145: begin
		    q <= 16'hb150;
		    ms <= ms_146;
		end
		ms_146: begin
		    q <= 16'hb0aa;
		    ms <= ms_147;
		end
		ms_147: begin
		    q <= 16'hb002;
		    ms <= ms_148;
		end
		ms_148: begin
		    q <= 16'haf56;
		    ms <= ms_149;
		end
		ms_149: begin
		    q <= 16'haea7;
		    ms <= ms_150;
		end
		ms_150: begin
		    q <= 16'hadf6;
		    ms <= ms_151;
		end
		ms_151: begin
		    q <= 16'had41;
		    ms <= ms_152;
		end
		ms_152: begin
		    q <= 16'hac8a;
		    ms <= ms_153;
		end
		ms_153: begin
		    q <= 16'habd0;
		    ms <= ms_154;
		end
		ms_154: begin
		    q <= 16'hab13;
		    ms <= ms_155;
		end
		ms_155: begin
		    q <= 16'haa53;
		    ms <= ms_156;
		end
		ms_156: begin
		    q <= 16'ha991;
		    ms <= ms_157;
		end
		ms_157: begin
		    q <= 16'ha8cc;
		    ms <= ms_158;
		end
		ms_158: begin
		    q <= 16'ha804;
		    ms <= ms_159;
		end
		ms_159: begin
		    q <= 16'ha73a;
		    ms <= ms_160;
		end
		ms_160: begin
		    q <= 16'ha66d;
		    ms <= ms_161;
		end
		ms_161: begin
		    q <= 16'ha59e;
		    ms <= ms_162;
		end
		ms_162: begin
		    q <= 16'ha4cd;
		    ms <= ms_163;
		end
		ms_163: begin
		    q <= 16'ha3f9;
		    ms <= ms_164;
		end
		ms_164: begin
		    q <= 16'ha323;
		    ms <= ms_165;
		end
		ms_165: begin
		    q <= 16'ha24b;
		    ms <= ms_166;
		end
		ms_166: begin
		    q <= 16'ha171;
		    ms <= ms_167;
		end
		ms_167: begin
		    q <= 16'ha094;
		    ms <= ms_168;
		end
		ms_168: begin
		    q <= 16'h9fb6;
		    ms <= ms_169;
		end
		ms_169: begin
		    q <= 16'h9ed5;
		    ms <= ms_170;
		end
		ms_170: begin
		    q <= 16'h9df3;
		    ms <= ms_171;
		end
		ms_171: begin
		    q <= 16'h9d0e;
		    ms <= ms_172;
		end
		ms_172: begin
		    q <= 16'h9c28;
		    ms <= ms_173;
		end
		ms_173: begin
		    q <= 16'h9b40;
		    ms <= ms_174;
		end
		ms_174: begin
		    q <= 16'h9a56;
		    ms <= ms_175;
		end
		ms_175: begin
		    q <= 16'h996b;
		    ms <= ms_176;
		end
		ms_176: begin
		    q <= 16'h987e;
		    ms <= ms_177;
		end
		ms_177: begin
		    q <= 16'h978f;
		    ms <= ms_178;
		end
		ms_178: begin
		    q <= 16'h969f;
		    ms <= ms_179;
		end
		ms_179: begin
		    q <= 16'h95ae;
		    ms <= ms_180;
		end
		ms_180: begin
		    q <= 16'h94bb;
		    ms <= ms_181;
		end
		ms_181: begin
		    q <= 16'h93c7;
		    ms <= ms_182;
		end
		ms_182: begin
		    q <= 16'h92d2;
		    ms <= ms_183;
		end
		ms_183: begin
		    q <= 16'h91db;
		    ms <= ms_184;
		end
		ms_184: begin
		    q <= 16'h90e3;
		    ms <= ms_185;
		end
		ms_185: begin
		    q <= 16'h8feb;
		    ms <= ms_186;
		end
		ms_186: begin
		    q <= 16'h8ef1;
		    ms <= ms_187;
		end
		ms_187: begin
		    q <= 16'h8df6;
		    ms <= ms_188;
		end
		ms_188: begin
		    q <= 16'h8cfa;
		    ms <= ms_189;
		end
		ms_189: begin
		    q <= 16'h8bfe;
		    ms <= ms_190;
		end
		ms_190: begin
		    q <= 16'h8b01;
		    ms <= ms_191;
		end
		ms_191: begin
		    q <= 16'h8a03;
		    ms <= ms_192;
		end
		ms_192: begin
		    q <= 16'h8905;
		    ms <= ms_193;
		end
		ms_193: begin
		    q <= 16'h8805;
		    ms <= ms_194;
		end
		ms_194: begin
		    q <= 16'h8706;
		    ms <= ms_195;
		end
		ms_195: begin
		    q <= 16'h8606;
		    ms <= ms_196;
		end
		ms_196: begin
		    q <= 16'h8505;
		    ms <= ms_197;
		end
		ms_197: begin
		    q <= 16'h8405;
		    ms <= ms_198;
		end
		ms_198: begin
		    q <= 16'h8304;
		    ms <= ms_199;
		end
		ms_199: begin
		    q <= 16'h8203;
		    ms <= ms_200;
		end
		ms_200: begin
		    q <= 16'h8101;
		    ms <= ms_201;
		end
		ms_201: begin
		    q <= 16'h8000;
		    ms <= ms_202;
		end
		ms_202: begin
		    q <= 16'h7eff;
		    ms <= ms_203;
		end
		ms_203: begin
		    q <= 16'h7dfd;
		    ms <= ms_204;
		end
		ms_204: begin
		    q <= 16'h7cfc;
		    ms <= ms_205;
		end
		ms_205: begin
		    q <= 16'h7bfb;
		    ms <= ms_206;
		end
		ms_206: begin
		    q <= 16'h7afb;
		    ms <= ms_207;
		end
		ms_207: begin
		    q <= 16'h79fa;
		    ms <= ms_208;
		end
		ms_208: begin
		    q <= 16'h78fa;
		    ms <= ms_209;
		end
		ms_209: begin
		    q <= 16'h77fb;
		    ms <= ms_210;
		end
		ms_210: begin
		    q <= 16'h76fb;
		    ms <= ms_211;
		end
		ms_211: begin
		    q <= 16'h75fd;
		    ms <= ms_212;
		end
		ms_212: begin
		    q <= 16'h74ff;
		    ms <= ms_213;
		end
		ms_213: begin
		    q <= 16'h7402;
		    ms <= ms_214;
		end
		ms_214: begin
		    q <= 16'h7306;
		    ms <= ms_215;
		end
		ms_215: begin
		    q <= 16'h720a;
		    ms <= ms_216;
		end
		ms_216: begin
		    q <= 16'h710f;
		    ms <= ms_217;
		end
		ms_217: begin
		    q <= 16'h7015;
		    ms <= ms_218;
		end
		ms_218: begin
		    q <= 16'h6f1d;
		    ms <= ms_219;
		end
		ms_219: begin
		    q <= 16'h6e25;
		    ms <= ms_220;
		end
		ms_220: begin
		    q <= 16'h6d2e;
		    ms <= ms_221;
		end
		ms_221: begin
		    q <= 16'h6c39;
		    ms <= ms_222;
		end
		ms_222: begin
		    q <= 16'h6b45;
		    ms <= ms_223;
		end
		ms_223: begin
		    q <= 16'h6a52;
		    ms <= ms_224;
		end
		ms_224: begin
		    q <= 16'h6961;
		    ms <= ms_225;
		end
		ms_225: begin
		    q <= 16'h6871;
		    ms <= ms_226;
		end
		ms_226: begin
		    q <= 16'h6782;
		    ms <= ms_227;
		end
		ms_227: begin
		    q <= 16'h6695;
		    ms <= ms_228;
		end
		ms_228: begin
		    q <= 16'h65aa;
		    ms <= ms_229;
		end
		ms_229: begin
		    q <= 16'h64c0;
		    ms <= ms_230;
		end
		ms_230: begin
		    q <= 16'h63d8;
		    ms <= ms_231;
		end
		ms_231: begin
		    q <= 16'h62f2;
		    ms <= ms_232;
		end
		ms_232: begin
		    q <= 16'h620d;
		    ms <= ms_233;
		end
		ms_233: begin
		    q <= 16'h612b;
		    ms <= ms_234;
		end
		ms_234: begin
		    q <= 16'h604a;
		    ms <= ms_235;
		end
		ms_235: begin
		    q <= 16'h5f6c;
		    ms <= ms_236;
		end
		ms_236: begin
		    q <= 16'h5e8f;
		    ms <= ms_237;
		end
		ms_237: begin
		    q <= 16'h5db5;
		    ms <= ms_238;
		end
		ms_238: begin
		    q <= 16'h5cdd;
		    ms <= ms_239;
		end
		ms_239: begin
		    q <= 16'h5c07;
		    ms <= ms_240;
		end
		ms_240: begin
		    q <= 16'h5b33;
		    ms <= ms_241;
		end
		ms_241: begin
		    q <= 16'h5a62;
		    ms <= ms_242;
		end
		ms_242: begin
		    q <= 16'h5993;
		    ms <= ms_243;
		end
		ms_243: begin
		    q <= 16'h58c6;
		    ms <= ms_244;
		end
		ms_244: begin
		    q <= 16'h57fc;
		    ms <= ms_245;
		end
		ms_245: begin
		    q <= 16'h5734;
		    ms <= ms_246;
		end
		ms_246: begin
		    q <= 16'h566f;
		    ms <= ms_247;
		end
		ms_247: begin
		    q <= 16'h55ad;
		    ms <= ms_248;
		end
		ms_248: begin
		    q <= 16'h54ed;
		    ms <= ms_249;
		end
		ms_249: begin
		    q <= 16'h5430;
		    ms <= ms_250;
		end
		ms_250: begin
		    q <= 16'h5376;
		    ms <= ms_251;
		end
		ms_251: begin
		    q <= 16'h52bf;
		    ms <= ms_252;
		end
		ms_252: begin
		    q <= 16'h520a;
		    ms <= ms_253;
		end
		ms_253: begin
		    q <= 16'h5159;
		    ms <= ms_254;
		end
		ms_254: begin
		    q <= 16'h50aa;
		    ms <= ms_255;
		end
		ms_255: begin
		    q <= 16'h4ffe;
		    ms <= ms_256;
		end
		ms_256: begin
		    q <= 16'h4f56;
		    ms <= ms_257;
		end
		ms_257: begin
		    q <= 16'h4eb0;
		    ms <= ms_258;
		end
		ms_258: begin
		    q <= 16'h4e0d;
		    ms <= ms_259;
		end
		ms_259: begin
		    q <= 16'h4d6e;
		    ms <= ms_260;
		end
		ms_260: begin
		    q <= 16'h4cd2;
		    ms <= ms_261;
		end
		ms_261: begin
		    q <= 16'h4c39;
		    ms <= ms_262;
		end
		ms_262: begin
		    q <= 16'h4ba3;
		    ms <= ms_263;
		end
		ms_263: begin
		    q <= 16'h4b11;
		    ms <= ms_264;
		end
		ms_264: begin
		    q <= 16'h4a82;
		    ms <= ms_265;
		end
		ms_265: begin
		    q <= 16'h49f7;
		    ms <= ms_266;
		end
		ms_266: begin
		    q <= 16'h496e;
		    ms <= ms_267;
		end
		ms_267: begin
		    q <= 16'h48ea;
		    ms <= ms_268;
		end
		ms_268: begin
		    q <= 16'h4868;
		    ms <= ms_269;
		end
		ms_269: begin
		    q <= 16'h47eb;
		    ms <= ms_270;
		end
		ms_270: begin
		    q <= 16'h4770;
		    ms <= ms_271;
		end
		ms_271: begin
		    q <= 16'h46fa;
		    ms <= ms_272;
		end
		ms_272: begin
		    q <= 16'h4687;
		    ms <= ms_273;
		end
		ms_273: begin
		    q <= 16'h4617;
		    ms <= ms_274;
		end
		ms_274: begin
		    q <= 16'h45ac;
		    ms <= ms_275;
		end
		ms_275: begin
		    q <= 16'h4544;
		    ms <= ms_276;
		end
		ms_276: begin
		    q <= 16'h44df;
		    ms <= ms_277;
		end
		ms_277: begin
		    q <= 16'h447f;
		    ms <= ms_278;
		end
		ms_278: begin
		    q <= 16'h4422;
		    ms <= ms_279;
		end
		ms_279: begin
		    q <= 16'h43c9;
		    ms <= ms_280;
		end
		ms_280: begin
		    q <= 16'h4373;
		    ms <= ms_281;
		end
		ms_281: begin
		    q <= 16'h4322;
		    ms <= ms_282;
		end
		ms_282: begin
		    q <= 16'h42d4;
		    ms <= ms_283;
		end
		ms_283: begin
		    q <= 16'h428b;
		    ms <= ms_284;
		end
		ms_284: begin
		    q <= 16'h4245;
		    ms <= ms_285;
		end
		ms_285: begin
		    q <= 16'h4203;
		    ms <= ms_286;
		end
		ms_286: begin
		    q <= 16'h41c5;
		    ms <= ms_287;
		end
		ms_287: begin
		    q <= 16'h418b;
		    ms <= ms_288;
		end
		ms_288: begin
		    q <= 16'h4154;
		    ms <= ms_289;
		end
		ms_289: begin
		    q <= 16'h4122;
		    ms <= ms_290;
		end
		ms_290: begin
		    q <= 16'h40f4;
		    ms <= ms_291;
		end
		ms_291: begin
		    q <= 16'h40ca;
		    ms <= ms_292;
		end
		ms_292: begin
		    q <= 16'h40a3;
		    ms <= ms_293;
		end
		ms_293: begin
		    q <= 16'h4081;
		    ms <= ms_294;
		end
		ms_294: begin
		    q <= 16'h4063;
		    ms <= ms_295;
		end
		ms_295: begin
		    q <= 16'h4049;
		    ms <= ms_296;
		end
		ms_296: begin
		    q <= 16'h4033;
		    ms <= ms_297;
		end
		ms_297: begin
		    q <= 16'h4020;
		    ms <= ms_298;
		end
		ms_298: begin
		    q <= 16'h4012;
		    ms <= ms_299;
		end
		ms_299: begin
		    q <= 16'h4008;
		    ms <= ms_300;
		end
		ms_300: begin
		    q <= 16'h4002;
		    ms <= ms_301;
		end
		ms_301: begin
		    q <= 16'h4000;
		    ms <= ms_302;
		end
		ms_302: begin
		    q <= 16'h4002;
		    ms <= ms_303;
		end
		ms_303: begin
		    q <= 16'h4008;
		    ms <= ms_304;
		end
		ms_304: begin
		    q <= 16'h4012;
		    ms <= ms_305;
		end
		ms_305: begin
		    q <= 16'h4020;
		    ms <= ms_306;
		end
		ms_306: begin
		    q <= 16'h4033;
		    ms <= ms_307;
		end
		ms_307: begin
		    q <= 16'h4049;
		    ms <= ms_308;
		end
		ms_308: begin
		    q <= 16'h4063;
		    ms <= ms_309;
		end
		ms_309: begin
		    q <= 16'h4081;
		    ms <= ms_310;
		end
		ms_310: begin
		    q <= 16'h40a3;
		    ms <= ms_311;
		end
		ms_311: begin
		    q <= 16'h40ca;
		    ms <= ms_312;
		end
		ms_312: begin
		    q <= 16'h40f4;
		    ms <= ms_313;
		end
		ms_313: begin
		    q <= 16'h4122;
		    ms <= ms_314;
		end
		ms_314: begin
		    q <= 16'h4154;
		    ms <= ms_315;
		end
		ms_315: begin
		    q <= 16'h418b;
		    ms <= ms_316;
		end
		ms_316: begin
		    q <= 16'h41c5;
		    ms <= ms_317;
		end
		ms_317: begin
		    q <= 16'h4203;
		    ms <= ms_318;
		end
		ms_318: begin
		    q <= 16'h4245;
		    ms <= ms_319;
		end
		ms_319: begin
		    q <= 16'h428b;
		    ms <= ms_320;
		end
		ms_320: begin
		    q <= 16'h42d4;
		    ms <= ms_321;
		end
		ms_321: begin
		    q <= 16'h4322;
		    ms <= ms_322;
		end
		ms_322: begin
		    q <= 16'h4373;
		    ms <= ms_323;
		end
		ms_323: begin
		    q <= 16'h43c9;
		    ms <= ms_324;
		end
		ms_324: begin
		    q <= 16'h4422;
		    ms <= ms_325;
		end
		ms_325: begin
		    q <= 16'h447f;
		    ms <= ms_326;
		end
		ms_326: begin
		    q <= 16'h44df;
		    ms <= ms_327;
		end
		ms_327: begin
		    q <= 16'h4544;
		    ms <= ms_328;
		end
		ms_328: begin
		    q <= 16'h45ac;
		    ms <= ms_329;
		end
		ms_329: begin
		    q <= 16'h4617;
		    ms <= ms_330;
		end
		ms_330: begin
		    q <= 16'h4687;
		    ms <= ms_331;
		end
		ms_331: begin
		    q <= 16'h46fa;
		    ms <= ms_332;
		end
		ms_332: begin
		    q <= 16'h4770;
		    ms <= ms_333;
		end
		ms_333: begin
		    q <= 16'h47eb;
		    ms <= ms_334;
		end
		ms_334: begin
		    q <= 16'h4868;
		    ms <= ms_335;
		end
		ms_335: begin
		    q <= 16'h48ea;
		    ms <= ms_336;
		end
		ms_336: begin
		    q <= 16'h496e;
		    ms <= ms_337;
		end
		ms_337: begin
		    q <= 16'h49f7;
		    ms <= ms_338;
		end
		ms_338: begin
		    q <= 16'h4a82;
		    ms <= ms_339;
		end
		ms_339: begin
		    q <= 16'h4b11;
		    ms <= ms_340;
		end
		ms_340: begin
		    q <= 16'h4ba3;
		    ms <= ms_341;
		end
		ms_341: begin
		    q <= 16'h4c39;
		    ms <= ms_342;
		end
		ms_342: begin
		    q <= 16'h4cd2;
		    ms <= ms_343;
		end
		ms_343: begin
		    q <= 16'h4d6e;
		    ms <= ms_344;
		end
		ms_344: begin
		    q <= 16'h4e0d;
		    ms <= ms_345;
		end
		ms_345: begin
		    q <= 16'h4eb0;
		    ms <= ms_346;
		end
		ms_346: begin
		    q <= 16'h4f56;
		    ms <= ms_347;
		end
		ms_347: begin
		    q <= 16'h4ffe;
		    ms <= ms_348;
		end
		ms_348: begin
		    q <= 16'h50aa;
		    ms <= ms_349;
		end
		ms_349: begin
		    q <= 16'h5159;
		    ms <= ms_350;
		end
		ms_350: begin
		    q <= 16'h520a;
		    ms <= ms_351;
		end
		ms_351: begin
		    q <= 16'h52bf;
		    ms <= ms_352;
		end
		ms_352: begin
		    q <= 16'h5376;
		    ms <= ms_353;
		end
		ms_353: begin
		    q <= 16'h5430;
		    ms <= ms_354;
		end
		ms_354: begin
		    q <= 16'h54ed;
		    ms <= ms_355;
		end
		ms_355: begin
		    q <= 16'h55ad;
		    ms <= ms_356;
		end
		ms_356: begin
		    q <= 16'h566f;
		    ms <= ms_357;
		end
		ms_357: begin
		    q <= 16'h5734;
		    ms <= ms_358;
		end
		ms_358: begin
		    q <= 16'h57fc;
		    ms <= ms_359;
		end
		ms_359: begin
		    q <= 16'h58c6;
		    ms <= ms_360;
		end
		ms_360: begin
		    q <= 16'h5993;
		    ms <= ms_361;
		end
		ms_361: begin
		    q <= 16'h5a62;
		    ms <= ms_362;
		end
		ms_362: begin
		    q <= 16'h5b33;
		    ms <= ms_363;
		end
		ms_363: begin
		    q <= 16'h5c07;
		    ms <= ms_364;
		end
		ms_364: begin
		    q <= 16'h5cdd;
		    ms <= ms_365;
		end
		ms_365: begin
		    q <= 16'h5db5;
		    ms <= ms_366;
		end
		ms_366: begin
		    q <= 16'h5e8f;
		    ms <= ms_367;
		end
		ms_367: begin
		    q <= 16'h5f6c;
		    ms <= ms_368;
		end
		ms_368: begin
		    q <= 16'h604a;
		    ms <= ms_369;
		end
		ms_369: begin
		    q <= 16'h612b;
		    ms <= ms_370;
		end
		ms_370: begin
		    q <= 16'h620d;
		    ms <= ms_371;
		end
		ms_371: begin
		    q <= 16'h62f2;
		    ms <= ms_372;
		end
		ms_372: begin
		    q <= 16'h63d8;
		    ms <= ms_373;
		end
		ms_373: begin
		    q <= 16'h64c0;
		    ms <= ms_374;
		end
		ms_374: begin
		    q <= 16'h65aa;
		    ms <= ms_375;
		end
		ms_375: begin
		    q <= 16'h6695;
		    ms <= ms_376;
		end
		ms_376: begin
		    q <= 16'h6782;
		    ms <= ms_377;
		end
		ms_377: begin
		    q <= 16'h6871;
		    ms <= ms_378;
		end
		ms_378: begin
		    q <= 16'h6961;
		    ms <= ms_379;
		end
		ms_379: begin
		    q <= 16'h6a52;
		    ms <= ms_380;
		end
		ms_380: begin
		    q <= 16'h6b45;
		    ms <= ms_381;
		end
		ms_381: begin
		    q <= 16'h6c39;
		    ms <= ms_382;
		end
		ms_382: begin
		    q <= 16'h6d2e;
		    ms <= ms_383;
		end
		ms_383: begin
		    q <= 16'h6e25;
		    ms <= ms_384;
		end
		ms_384: begin
		    q <= 16'h6f1d;
		    ms <= ms_385;
		end
		ms_385: begin
		    q <= 16'h7015;
		    ms <= ms_386;
		end
		ms_386: begin
		    q <= 16'h710f;
		    ms <= ms_387;
		end
		ms_387: begin
		    q <= 16'h720a;
		    ms <= ms_388;
		end
		ms_388: begin
		    q <= 16'h7306;
		    ms <= ms_389;
		end
		ms_389: begin
		    q <= 16'h7402;
		    ms <= ms_390;
		end
		ms_390: begin
		    q <= 16'h74ff;
		    ms <= ms_391;
		end
		ms_391: begin
		    q <= 16'h75fd;
		    ms <= ms_392;
		end
		ms_392: begin
		    q <= 16'h76fb;
		    ms <= ms_393;
		end
		ms_393: begin
		    q <= 16'h77fb;
		    ms <= ms_394;
		end
		ms_394: begin
		    q <= 16'h78fa;
		    ms <= ms_395;
		end
		ms_395: begin
		    q <= 16'h79fa;
		    ms <= ms_396;
		end
		ms_396: begin
		    q <= 16'h7afb;
		    ms <= ms_397;
		end
		ms_397: begin
		    q <= 16'h7bfb;
		    ms <= ms_398;
		end
		ms_398: begin
		    q <= 16'h7cfc;
		    ms <= ms_399;
		end
		ms_399: begin
		    q <= 16'h7dfd;
		    ms <= ms_400;
		end
		ms_400: begin
		    q <= 16'h7eff;
		    if (send) begin
		        ms <= ms_1;
		    end else begin
		        ms <= ms_pause;
		    end
		end
		default: begin
		    q <= 16'h8000;
		    ms <= ms_pause;
		end
	    endcase
	end
end

endmodule
