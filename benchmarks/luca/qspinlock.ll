; ModuleID = '/Users/thomashaas/ExternalTools/cna-verification/client-code.c'
source_filename = "/Users/thomashaas/ExternalTools/cna-verification/client-code.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx16.0.0"

%struct.qnode = type { %struct.mcs_spinlock }
%struct.mcs_spinlock = type { ptr, i32, i32 }
%struct.qspinlock = type { %union.anon }
%union.anon = type { %struct.atomic_t }
%struct.atomic_t = type { i32 }

@tid = thread_local global i32 0, align 4, !dbg !0
@qnodes = internal global [1 x [4 x %struct.qnode]] zeroinitializer, align 8, !dbg !70
@x = internal global i32 0, align 4, !dbg !110
@y = internal global i32 0, align 4, !dbg !112
@__func__.main = private unnamed_addr constant [5 x i8] c"main\00", align 1, !dbg !52
@.str = private unnamed_addr constant [14 x i8] c"client-code.c\00", align 1, !dbg !60
@.str.1 = private unnamed_addr constant [7 x i8] c"x == y\00", align 1, !dbg !65
@lock = global %struct.qspinlock zeroinitializer, align 4, !dbg !77

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @queued_spin_lock_slowpath(ptr noundef %0, i32 noundef %1) #0 !dbg !121 {
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca ptr, align 8
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  %12 = alloca ptr, align 8
  %13 = alloca i32, align 4
  %14 = alloca i32, align 4
  %15 = alloca i32, align 4
  %16 = alloca ptr, align 8
  %17 = alloca i32, align 4
  %18 = alloca i32, align 4
  %19 = alloca i32, align 4
  %20 = alloca i32, align 4
  %21 = alloca ptr, align 8
  %22 = alloca i32, align 4
  %23 = alloca i32, align 4
  %24 = alloca i32, align 4
  %25 = alloca i32, align 4
  %26 = alloca ptr, align 8
  %27 = alloca i32, align 4
  %28 = alloca i32, align 4
  %29 = alloca i32, align 4
  %30 = alloca i32, align 4
  %31 = alloca i32, align 4
  %32 = alloca ptr, align 8
  %33 = alloca ptr, align 8
  %34 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  call void @llvm.dbg.declare(metadata ptr %3, metadata !128, metadata !DIExpression()), !dbg !129
  store i32 %1, ptr %4, align 4
  call void @llvm.dbg.declare(metadata ptr %4, metadata !130, metadata !DIExpression()), !dbg !131
  call void @llvm.dbg.declare(metadata ptr %5, metadata !132, metadata !DIExpression()), !dbg !133
  call void @llvm.dbg.declare(metadata ptr %6, metadata !134, metadata !DIExpression()), !dbg !135
  call void @llvm.dbg.declare(metadata ptr %7, metadata !136, metadata !DIExpression()), !dbg !137
  call void @llvm.dbg.declare(metadata ptr %8, metadata !138, metadata !DIExpression()), !dbg !139
  call void @llvm.dbg.declare(metadata ptr %9, metadata !140, metadata !DIExpression()), !dbg !141
  call void @llvm.dbg.declare(metadata ptr %10, metadata !142, metadata !DIExpression()), !dbg !143
  %35 = load ptr, ptr %3, align 8, !dbg !144
  %36 = call zeroext i1 @virt_spin_lock(ptr noundef %35), !dbg !146
  br i1 %36, label %37, label %38, !dbg !147

37:                                               ; preds = %2
  br label %273, !dbg !148

38:                                               ; preds = %2
  %39 = load i32, ptr %4, align 4, !dbg !149
  %40 = icmp eq i32 %39, 256, !dbg !151
  br i1 %40, label %41, label %62, !dbg !152

41:                                               ; preds = %38
  call void @llvm.dbg.declare(metadata ptr %11, metadata !153, metadata !DIExpression()), !dbg !155
  store i32 1, ptr %11, align 4, !dbg !155
  call void @llvm.dbg.declare(metadata ptr %12, metadata !156, metadata !DIExpression()), !dbg !159
  %42 = load ptr, ptr %3, align 8, !dbg !159
  %43 = getelementptr inbounds %struct.qspinlock, ptr %42, i32 0, i32 0, !dbg !159
  %44 = getelementptr inbounds %struct.atomic_t, ptr %43, i32 0, i32 0, !dbg !159
  store ptr %44, ptr %12, align 8, !dbg !159
  call void @llvm.dbg.declare(metadata ptr %13, metadata !160, metadata !DIExpression()), !dbg !159
  br label %45, !dbg !159

45:                                               ; preds = %58, %41
  %46 = load ptr, ptr %12, align 8, !dbg !161
  %47 = call i64 @__LKMM_load(ptr noundef %46, i64 noundef 4, i32 noundef 0), !dbg !161
  %48 = trunc i64 %47 to i32, !dbg !161
  store i32 %48, ptr %13, align 4, !dbg !161
  %49 = load i32, ptr %13, align 4, !dbg !165
  %50 = icmp ne i32 %49, 256, !dbg !165
  br i1 %50, label %55, label %51, !dbg !165

51:                                               ; preds = %45
  %52 = load i32, ptr %11, align 4, !dbg !165
  %53 = add nsw i32 %52, -1, !dbg !165
  store i32 %53, ptr %11, align 4, !dbg !165
  %54 = icmp ne i32 %52, 0, !dbg !165
  br i1 %54, label %56, label %55, !dbg !161

55:                                               ; preds = %51, %45
  br label %59, !dbg !165

56:                                               ; preds = %51
  br label %57, !dbg !161

57:                                               ; preds = %56
  br label %58, !dbg !167

58:                                               ; preds = %57
  br label %45, !dbg !169, !llvm.loop !170

59:                                               ; preds = %55
  %60 = load i32, ptr %13, align 4, !dbg !159
  store i32 %60, ptr %14, align 4, !dbg !171
  %61 = load i32, ptr %14, align 4, !dbg !159
  store i32 %61, ptr %4, align 4, !dbg !172
  br label %62, !dbg !173

62:                                               ; preds = %59, %38
  %63 = load i32, ptr %4, align 4, !dbg !174
  %64 = and i32 %63, -256, !dbg !176
  %65 = icmp ne i32 %64, 0, !dbg !176
  br i1 %65, label %66, label %67, !dbg !177

66:                                               ; preds = %62
  br label %106, !dbg !178

67:                                               ; preds = %62
  %68 = load ptr, ptr %3, align 8, !dbg !179
  %69 = call i32 @queued_fetch_set_pending_acquire(ptr noundef %68), !dbg !180
  store i32 %69, ptr %4, align 4, !dbg !181
  %70 = load i32, ptr %4, align 4, !dbg !182
  %71 = and i32 %70, -256, !dbg !182
  %72 = icmp ne i32 %71, 0, !dbg !182
  br i1 %72, label %73, label %80, !dbg !184

73:                                               ; preds = %67
  %74 = load i32, ptr %4, align 4, !dbg !185
  %75 = and i32 %74, 65280, !dbg !188
  %76 = icmp ne i32 %75, 0, !dbg !188
  br i1 %76, label %79, label %77, !dbg !189

77:                                               ; preds = %73
  %78 = load ptr, ptr %3, align 8, !dbg !190
  call void @clear_pending(ptr noundef %78), !dbg !191
  br label %79, !dbg !191

79:                                               ; preds = %77, %73
  br label %106, !dbg !192

80:                                               ; preds = %67
  %81 = load i32, ptr %4, align 4, !dbg !193
  %82 = and i32 %81, 255, !dbg !195
  %83 = icmp ne i32 %82, 0, !dbg !195
  br i1 %83, label %84, label %104, !dbg !196

84:                                               ; preds = %80
  call void @llvm.dbg.declare(metadata ptr %15, metadata !197, metadata !DIExpression()), !dbg !199
  call void @llvm.dbg.declare(metadata ptr %16, metadata !200, metadata !DIExpression()), !dbg !202
  %85 = load ptr, ptr %3, align 8, !dbg !202
  %86 = getelementptr inbounds %struct.qspinlock, ptr %85, i32 0, i32 0, !dbg !202
  %87 = getelementptr inbounds %struct.atomic_t, ptr %86, i32 0, i32 0, !dbg !202
  store ptr %87, ptr %16, align 8, !dbg !202
  call void @llvm.dbg.declare(metadata ptr %17, metadata !203, metadata !DIExpression()), !dbg !202
  br label %88, !dbg !202

88:                                               ; preds = %98, %84
  %89 = load ptr, ptr %16, align 8, !dbg !204
  %90 = call i64 @__LKMM_load(ptr noundef %89, i64 noundef 4, i32 noundef 0), !dbg !204
  %91 = trunc i64 %90 to i32, !dbg !204
  store i32 %91, ptr %17, align 4, !dbg !204
  %92 = load i32, ptr %17, align 4, !dbg !208
  %93 = and i32 %92, 255, !dbg !208
  %94 = icmp ne i32 %93, 0, !dbg !208
  br i1 %94, label %96, label %95, !dbg !204

95:                                               ; preds = %88
  br label %99, !dbg !208

96:                                               ; preds = %88
  br label %97, !dbg !204

97:                                               ; preds = %96
  br label %98, !dbg !210

98:                                               ; preds = %97
  br label %88, !dbg !212, !llvm.loop !213

99:                                               ; preds = %95
  %100 = load i32, ptr %17, align 4, !dbg !202
  store i32 %100, ptr %18, align 4, !dbg !214
  %101 = load i32, ptr %18, align 4, !dbg !202
  store i32 %101, ptr %15, align 4, !dbg !199
  call void @__LKMM_fence(i32 noundef 5), !dbg !199
  %102 = load i32, ptr %15, align 4, !dbg !199
  store i32 %102, ptr %19, align 4, !dbg !199
  %103 = load i32, ptr %19, align 4, !dbg !199
  br label %104, !dbg !215

104:                                              ; preds = %99, %80
  %105 = load ptr, ptr %3, align 8, !dbg !216
  call void @clear_pending_set_locked(ptr noundef %105), !dbg !217
  br label %273, !dbg !218

106:                                              ; preds = %79, %66
  call void @llvm.dbg.label(metadata !219), !dbg !220
  br label %107, !dbg !218

107:                                              ; preds = %106
  call void @llvm.dbg.label(metadata !221), !dbg !222
  %108 = call align 4 ptr @llvm.threadlocal.address.p0(ptr align 4 @tid), !dbg !223
  %109 = load i32, ptr %108, align 4, !dbg !223
  %110 = call ptr @get_node(i32 noundef %109), !dbg !223
  store ptr %110, ptr %7, align 8, !dbg !224
  %111 = load ptr, ptr %7, align 8, !dbg !225
  %112 = getelementptr inbounds %struct.mcs_spinlock, ptr %111, i32 0, i32 2, !dbg !226
  %113 = load i32, ptr %112, align 4, !dbg !227
  %114 = add nsw i32 %113, 1, !dbg !227
  store i32 %114, ptr %112, align 4, !dbg !227
  store i32 %113, ptr %10, align 4, !dbg !228
  %115 = call align 4 ptr @llvm.threadlocal.address.p0(ptr align 4 @tid), !dbg !229
  %116 = load i32, ptr %115, align 4, !dbg !229
  %117 = load i32, ptr %10, align 4, !dbg !230
  %118 = call i32 @encode_tail(i32 noundef %116, i32 noundef %117), !dbg !231
  store i32 %118, ptr %9, align 4, !dbg !232
  %119 = load i32, ptr %10, align 4, !dbg !233
  %120 = icmp sge i32 %119, 1, !dbg !233
  br i1 %120, label %121, label %131, !dbg !235

121:                                              ; preds = %107
  br label %122, !dbg !236

122:                                              ; preds = %129, %121
  %123 = load ptr, ptr %3, align 8, !dbg !238
  %124 = call i32 @queued_spin_trylock(ptr noundef %123), !dbg !239
  %125 = icmp ne i32 %124, 0, !dbg !240
  %126 = xor i1 %125, true, !dbg !240
  br i1 %126, label %127, label %130, !dbg !236

127:                                              ; preds = %122
  br label %128, !dbg !241

128:                                              ; preds = %127
  br label %129, !dbg !242

129:                                              ; preds = %128
  br label %122, !dbg !236, !llvm.loop !244

130:                                              ; preds = %122
  br label %266, !dbg !246

131:                                              ; preds = %107
  %132 = load ptr, ptr %7, align 8, !dbg !247
  %133 = load i32, ptr %10, align 4, !dbg !248
  %134 = call ptr @grab_mcs_node(ptr noundef %132, i32 noundef %133), !dbg !249
  store ptr %134, ptr %7, align 8, !dbg !250
  br label %135, !dbg !251

135:                                              ; preds = %131
  %136 = load i32, ptr %10, align 4, !dbg !252
  br label %137, !dbg !252

137:                                              ; preds = %135
  call void @__LKMM_fence(i32 noundef 12), !dbg !254
  %138 = load ptr, ptr %7, align 8, !dbg !255
  %139 = getelementptr inbounds %struct.mcs_spinlock, ptr %138, i32 0, i32 1, !dbg !256
  store i32 0, ptr %139, align 8, !dbg !257
  %140 = load ptr, ptr %7, align 8, !dbg !258
  %141 = getelementptr inbounds %struct.mcs_spinlock, ptr %140, i32 0, i32 0, !dbg !259
  store ptr null, ptr %141, align 8, !dbg !260
  %142 = load ptr, ptr %7, align 8, !dbg !261
  call void @__pv_init_node(ptr noundef %142), !dbg !262
  %143 = load ptr, ptr %3, align 8, !dbg !263
  %144 = call i32 @queued_spin_trylock(ptr noundef %143), !dbg !265
  %145 = icmp ne i32 %144, 0, !dbg !265
  br i1 %145, label %146, label %147, !dbg !266

146:                                              ; preds = %137
  br label %266, !dbg !267

147:                                              ; preds = %137
  call void @__LKMM_fence(i32 noundef 4), !dbg !268
  %148 = load ptr, ptr %3, align 8, !dbg !269
  %149 = load i32, ptr %9, align 4, !dbg !270
  %150 = call i32 @xchg_tail(ptr noundef %148, i32 noundef %149), !dbg !271
  store i32 %150, ptr %8, align 4, !dbg !272
  store ptr null, ptr %6, align 8, !dbg !273
  %151 = load i32, ptr %8, align 4, !dbg !274
  %152 = and i32 %151, -65536, !dbg !276
  %153 = icmp ne i32 %152, 0, !dbg !276
  br i1 %153, label %154, label %190, !dbg !277

154:                                              ; preds = %147
  %155 = load i32, ptr %8, align 4, !dbg !278
  %156 = call ptr @decode_tail(i32 noundef %155, ptr noundef @qnodes), !dbg !280
  store ptr %156, ptr %5, align 8, !dbg !281
  %157 = load ptr, ptr %5, align 8, !dbg !282
  %158 = getelementptr inbounds %struct.mcs_spinlock, ptr %157, i32 0, i32 0, !dbg !282
  %159 = load ptr, ptr %7, align 8, !dbg !282
  %160 = ptrtoint ptr %159 to i64, !dbg !282
  call void @__LKMM_store(ptr noundef %158, i64 noundef 8, i64 noundef %160, i32 noundef 0), !dbg !282
  %161 = load ptr, ptr %7, align 8, !dbg !283
  %162 = load ptr, ptr %5, align 8, !dbg !284
  call void @__pv_wait_node(ptr noundef %161, ptr noundef %162), !dbg !285
  call void @llvm.dbg.declare(metadata ptr %20, metadata !286, metadata !DIExpression()), !dbg !288
  call void @llvm.dbg.declare(metadata ptr %21, metadata !289, metadata !DIExpression()), !dbg !291
  %163 = load ptr, ptr %7, align 8, !dbg !291
  %164 = getelementptr inbounds %struct.mcs_spinlock, ptr %163, i32 0, i32 1, !dbg !291
  store ptr %164, ptr %21, align 8, !dbg !291
  call void @llvm.dbg.declare(metadata ptr %22, metadata !292, metadata !DIExpression()), !dbg !291
  br label %165, !dbg !291

165:                                              ; preds = %174, %154
  %166 = load ptr, ptr %21, align 8, !dbg !293
  %167 = call i64 @__LKMM_load(ptr noundef %166, i64 noundef 4, i32 noundef 0), !dbg !293
  %168 = trunc i64 %167 to i32, !dbg !293
  store i32 %168, ptr %22, align 4, !dbg !293
  %169 = load i32, ptr %22, align 4, !dbg !297
  %170 = icmp ne i32 %169, 0, !dbg !297
  br i1 %170, label %171, label %172, !dbg !293

171:                                              ; preds = %165
  br label %175, !dbg !297

172:                                              ; preds = %165
  br label %173, !dbg !293

173:                                              ; preds = %172
  br label %174, !dbg !299

174:                                              ; preds = %173
  br label %165, !dbg !301, !llvm.loop !302

175:                                              ; preds = %171
  %176 = load i32, ptr %22, align 4, !dbg !291
  store i32 %176, ptr %23, align 4, !dbg !303
  %177 = load i32, ptr %23, align 4, !dbg !291
  store i32 %177, ptr %20, align 4, !dbg !288
  call void @__LKMM_fence(i32 noundef 5), !dbg !288
  %178 = load i32, ptr %20, align 4, !dbg !288
  store i32 %178, ptr %24, align 4, !dbg !288
  %179 = load i32, ptr %24, align 4, !dbg !288
  %180 = load ptr, ptr %7, align 8, !dbg !304
  %181 = getelementptr inbounds %struct.mcs_spinlock, ptr %180, i32 0, i32 0, !dbg !304
  %182 = call i64 @__LKMM_load(ptr noundef %181, i64 noundef 8, i32 noundef 0), !dbg !304
  %183 = inttoptr i64 %182 to ptr, !dbg !304
  store ptr %183, ptr %6, align 8, !dbg !305
  %184 = load ptr, ptr %6, align 8, !dbg !306
  %185 = icmp ne ptr %184, null, !dbg !306
  br i1 %185, label %186, label %189, !dbg !308

186:                                              ; preds = %175
  br label %187, !dbg !309

187:                                              ; preds = %186
  br label %188, !dbg !310

188:                                              ; preds = %187
  br label %189, !dbg !310

189:                                              ; preds = %188, %175
  br label %190, !dbg !312

190:                                              ; preds = %189, %147
  %191 = load ptr, ptr %3, align 8, !dbg !313
  %192 = load ptr, ptr %7, align 8, !dbg !315
  %193 = call i32 @__pv_wait_head_or_lock(ptr noundef %191, ptr noundef %192), !dbg !316
  store i32 %193, ptr %4, align 4, !dbg !317
  %194 = icmp ne i32 %193, 0, !dbg !317
  br i1 %194, label %195, label %196, !dbg !318

195:                                              ; preds = %190
  br label %216, !dbg !319

196:                                              ; preds = %190
  call void @llvm.dbg.declare(metadata ptr %25, metadata !320, metadata !DIExpression()), !dbg !322
  call void @llvm.dbg.declare(metadata ptr %26, metadata !323, metadata !DIExpression()), !dbg !325
  %197 = load ptr, ptr %3, align 8, !dbg !325
  %198 = getelementptr inbounds %struct.qspinlock, ptr %197, i32 0, i32 0, !dbg !325
  %199 = getelementptr inbounds %struct.atomic_t, ptr %198, i32 0, i32 0, !dbg !325
  store ptr %199, ptr %26, align 8, !dbg !325
  call void @llvm.dbg.declare(metadata ptr %27, metadata !326, metadata !DIExpression()), !dbg !325
  br label %200, !dbg !325

200:                                              ; preds = %210, %196
  %201 = load ptr, ptr %26, align 8, !dbg !327
  %202 = call i64 @__LKMM_load(ptr noundef %201, i64 noundef 4, i32 noundef 0), !dbg !327
  %203 = trunc i64 %202 to i32, !dbg !327
  store i32 %203, ptr %27, align 4, !dbg !327
  %204 = load i32, ptr %27, align 4, !dbg !331
  %205 = and i32 %204, 65535, !dbg !331
  %206 = icmp ne i32 %205, 0, !dbg !331
  br i1 %206, label %208, label %207, !dbg !327

207:                                              ; preds = %200
  br label %211, !dbg !331

208:                                              ; preds = %200
  br label %209, !dbg !327

209:                                              ; preds = %208
  br label %210, !dbg !333

210:                                              ; preds = %209
  br label %200, !dbg !335, !llvm.loop !336

211:                                              ; preds = %207
  %212 = load i32, ptr %27, align 4, !dbg !325
  store i32 %212, ptr %28, align 4, !dbg !337
  %213 = load i32, ptr %28, align 4, !dbg !325
  store i32 %213, ptr %25, align 4, !dbg !322
  call void @__LKMM_fence(i32 noundef 5), !dbg !322
  %214 = load i32, ptr %25, align 4, !dbg !322
  store i32 %214, ptr %29, align 4, !dbg !322
  %215 = load i32, ptr %29, align 4, !dbg !322
  store i32 %215, ptr %4, align 4, !dbg !338
  br label %216, !dbg !339

216:                                              ; preds = %211, %195
  call void @llvm.dbg.label(metadata !340), !dbg !341
  %217 = load i32, ptr %4, align 4, !dbg !342
  %218 = and i32 %217, -65536, !dbg !344
  %219 = load i32, ptr %9, align 4, !dbg !345
  %220 = icmp eq i32 %218, %219, !dbg !346
  br i1 %220, label %221, label %241, !dbg !347

221:                                              ; preds = %216
  call void @llvm.dbg.declare(metadata ptr %30, metadata !348, metadata !DIExpression()), !dbg !352
  %222 = load ptr, ptr %3, align 8, !dbg !352
  %223 = getelementptr inbounds %struct.qspinlock, ptr %222, i32 0, i32 0, !dbg !352
  %224 = getelementptr inbounds %struct.atomic_t, ptr %223, i32 0, i32 0, !dbg !352
  %225 = load i32, ptr %4, align 4, !dbg !352
  %226 = sext i32 %225 to i64, !dbg !352
  %227 = call i64 @__LKMM_cmpxchg(ptr noundef %224, i64 noundef 4, i64 noundef %226, i64 noundef 1, i32 noundef 0, i32 noundef 0), !dbg !352
  %228 = trunc i64 %227 to i32, !dbg !352
  store i32 %228, ptr %30, align 4, !dbg !352
  %229 = load i32, ptr %30, align 4, !dbg !352
  %230 = load i32, ptr %4, align 4, !dbg !352
  %231 = icmp eq i32 %229, %230, !dbg !352
  br i1 %231, label %232, label %233, !dbg !352

232:                                              ; preds = %221
  br label %235, !dbg !352

233:                                              ; preds = %221
  %234 = load i32, ptr %30, align 4, !dbg !352
  store i32 %234, ptr %4, align 4, !dbg !352
  br label %235, !dbg !352

235:                                              ; preds = %233, %232
  %236 = phi i32 [ 1, %232 ], [ 0, %233 ], !dbg !352
  store i32 %236, ptr %31, align 4, !dbg !352
  %237 = load i32, ptr %31, align 4, !dbg !352
  %238 = icmp ne i32 %237, 0, !dbg !353
  br i1 %238, label %239, label %240, !dbg !354

239:                                              ; preds = %235
  br label %266, !dbg !355

240:                                              ; preds = %235
  br label %241, !dbg !356

241:                                              ; preds = %240, %216
  %242 = load ptr, ptr %3, align 8, !dbg !357
  call void @set_locked(ptr noundef %242), !dbg !358
  %243 = load ptr, ptr %6, align 8, !dbg !359
  %244 = icmp ne ptr %243, null, !dbg !359
  br i1 %244, label %261, label %245, !dbg !361

245:                                              ; preds = %241
  call void @llvm.dbg.declare(metadata ptr %32, metadata !362, metadata !DIExpression()), !dbg !365
  %246 = load ptr, ptr %7, align 8, !dbg !365
  %247 = getelementptr inbounds %struct.mcs_spinlock, ptr %246, i32 0, i32 0, !dbg !365
  store ptr %247, ptr %32, align 8, !dbg !365
  call void @llvm.dbg.declare(metadata ptr %33, metadata !366, metadata !DIExpression()), !dbg !365
  br label %248, !dbg !365

248:                                              ; preds = %257, %245
  %249 = load ptr, ptr %32, align 8, !dbg !367
  %250 = call i64 @__LKMM_load(ptr noundef %249, i64 noundef 8, i32 noundef 0), !dbg !367
  %251 = inttoptr i64 %250 to ptr, !dbg !367
  store ptr %251, ptr %33, align 8, !dbg !367
  %252 = load ptr, ptr %33, align 8, !dbg !371
  %253 = icmp ne ptr %252, null, !dbg !371
  br i1 %253, label %254, label %255, !dbg !367

254:                                              ; preds = %248
  br label %258, !dbg !371

255:                                              ; preds = %248
  br label %256, !dbg !367

256:                                              ; preds = %255
  br label %257, !dbg !373

257:                                              ; preds = %256
  br label %248, !dbg !375, !llvm.loop !376

258:                                              ; preds = %254
  %259 = load ptr, ptr %33, align 8, !dbg !365
  store ptr %259, ptr %34, align 8, !dbg !377
  %260 = load ptr, ptr %34, align 8, !dbg !365
  store ptr %260, ptr %6, align 8, !dbg !378
  br label %261, !dbg !379

261:                                              ; preds = %258, %241
  %262 = load ptr, ptr %6, align 8, !dbg !380
  %263 = getelementptr inbounds %struct.mcs_spinlock, ptr %262, i32 0, i32 1, !dbg !380
  call void @__LKMM_store(ptr noundef %263, i64 noundef 4, i64 noundef 1, i32 noundef 2), !dbg !380
  %264 = load ptr, ptr %3, align 8, !dbg !381
  %265 = load ptr, ptr %6, align 8, !dbg !382
  call void @__pv_kick_node(ptr noundef %264, ptr noundef %265), !dbg !383
  br label %266, !dbg !383

266:                                              ; preds = %261, %239, %146, %130
  call void @llvm.dbg.label(metadata !384), !dbg !385
  %267 = call align 4 ptr @llvm.threadlocal.address.p0(ptr align 4 @tid), !dbg !386
  %268 = load i32, ptr %267, align 4, !dbg !386
  %269 = call ptr @get_node(i32 noundef %268), !dbg !386
  %270 = getelementptr inbounds %struct.mcs_spinlock, ptr %269, i32 0, i32 2, !dbg !386
  %271 = load i32, ptr %270, align 4, !dbg !386
  %272 = add nsw i32 %271, -1, !dbg !386
  store i32 %272, ptr %270, align 4, !dbg !386
  br label %273, !dbg !387

273:                                              ; preds = %266, %104, %37
  ret void, !dbg !387
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind ssp uwtable(sync)
define internal zeroext i1 @virt_spin_lock(ptr noundef %0) #0 !dbg !388 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  call void @llvm.dbg.declare(metadata ptr %2, metadata !393, metadata !DIExpression()), !dbg !394
  ret i1 false, !dbg !395
}

declare i64 @__LKMM_load(ptr noundef, i64 noundef, i32 noundef) #2

; Function Attrs: noinline nounwind ssp uwtable(sync)
define internal i32 @queued_fetch_set_pending_acquire(ptr noundef %0) #0 !dbg !396 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  call void @llvm.dbg.declare(metadata ptr %2, metadata !399, metadata !DIExpression()), !dbg !400
  %3 = load ptr, ptr %2, align 8, !dbg !401
  %4 = getelementptr inbounds %struct.qspinlock, ptr %3, i32 0, i32 0, !dbg !401
  %5 = getelementptr inbounds %struct.atomic_t, ptr %4, i32 0, i32 0, !dbg !401
  %6 = call i64 @__LKMM_atomic_fetch_op(ptr noundef %5, i64 noundef 4, i64 noundef 256, i32 noundef 1, i32 noundef 3), !dbg !401
  %7 = trunc i64 %6 to i32, !dbg !401
  ret i32 %7, !dbg !402
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define internal void @clear_pending(ptr noundef %0) #0 !dbg !403 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  call void @llvm.dbg.declare(metadata ptr %2, metadata !406, metadata !DIExpression()), !dbg !407
  %3 = load ptr, ptr %2, align 8, !dbg !408
  %4 = getelementptr inbounds %struct.qspinlock, ptr %3, i32 0, i32 0, !dbg !408
  %5 = getelementptr inbounds %struct.atomic_t, ptr %4, i32 0, i32 0, !dbg !408
  call void @__LKMM_atomic_op(ptr noundef %5, i64 noundef 4, i64 noundef 4294967039, i32 noundef 2), !dbg !408
  ret void, !dbg !409
}

declare void @__LKMM_fence(i32 noundef) #2

; Function Attrs: noinline nounwind ssp uwtable(sync)
define internal void @clear_pending_set_locked(ptr noundef %0) #0 !dbg !410 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  call void @llvm.dbg.declare(metadata ptr %2, metadata !411, metadata !DIExpression()), !dbg !412
  %3 = load ptr, ptr %2, align 8, !dbg !413
  %4 = getelementptr inbounds %struct.qspinlock, ptr %3, i32 0, i32 0, !dbg !413
  %5 = getelementptr inbounds %struct.atomic_t, ptr %4, i32 0, i32 0, !dbg !413
  call void @__LKMM_atomic_op(ptr noundef %5, i64 noundef 4, i64 noundef 4294967041, i32 noundef 0), !dbg !413
  ret void, !dbg !414
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare void @llvm.dbg.label(metadata) #1

; Function Attrs: noinline nounwind ssp uwtable(sync)
define internal ptr @get_node(i32 noundef %0) #0 !dbg !415 {
  %2 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  call void @llvm.dbg.declare(metadata ptr %2, metadata !418, metadata !DIExpression()), !dbg !419
  %3 = load i32, ptr %2, align 4, !dbg !420
  %4 = sext i32 %3 to i64, !dbg !421
  %5 = getelementptr inbounds [4 x %struct.qnode], ptr @qnodes, i64 0, i64 %4, !dbg !421
  ret ptr %5, !dbg !422
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare nonnull ptr @llvm.threadlocal.address.p0(ptr nonnull) #1

; Function Attrs: noinline nounwind ssp uwtable(sync)
define internal i32 @encode_tail(i32 noundef %0, i32 noundef %1) #0 !dbg !423 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  store i32 %0, ptr %3, align 4
  call void @llvm.dbg.declare(metadata ptr %3, metadata !426, metadata !DIExpression()), !dbg !427
  store i32 %1, ptr %4, align 4
  call void @llvm.dbg.declare(metadata ptr %4, metadata !428, metadata !DIExpression()), !dbg !429
  call void @llvm.dbg.declare(metadata ptr %5, metadata !430, metadata !DIExpression()), !dbg !431
  %6 = load i32, ptr %3, align 4, !dbg !432
  %7 = add nsw i32 %6, 1, !dbg !433
  %8 = shl i32 %7, 18, !dbg !434
  store i32 %8, ptr %5, align 4, !dbg !435
  %9 = load i32, ptr %4, align 4, !dbg !436
  %10 = shl i32 %9, 16, !dbg !437
  %11 = load i32, ptr %5, align 4, !dbg !438
  %12 = or i32 %11, %10, !dbg !438
  store i32 %12, ptr %5, align 4, !dbg !438
  %13 = load i32, ptr %5, align 4, !dbg !439
  ret i32 %13, !dbg !440
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define internal i32 @queued_spin_trylock(ptr noundef %0) #0 !dbg !441 {
  %2 = alloca i32, align 4
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store ptr %0, ptr %3, align 8
  call void @llvm.dbg.declare(metadata ptr %3, metadata !444, metadata !DIExpression()), !dbg !445
  call void @llvm.dbg.declare(metadata ptr %4, metadata !446, metadata !DIExpression()), !dbg !447
  %7 = load ptr, ptr %3, align 8, !dbg !448
  %8 = getelementptr inbounds %struct.qspinlock, ptr %7, i32 0, i32 0, !dbg !448
  %9 = getelementptr inbounds %struct.atomic_t, ptr %8, i32 0, i32 0, !dbg !448
  %10 = call i64 @__LKMM_load(ptr noundef %9, i64 noundef 4, i32 noundef 0), !dbg !448
  %11 = trunc i64 %10 to i32, !dbg !448
  store i32 %11, ptr %4, align 4, !dbg !447
  %12 = load i32, ptr %4, align 4, !dbg !449
  %13 = icmp ne i32 %12, 0, !dbg !449
  br i1 %13, label %14, label %15, !dbg !451

14:                                               ; preds = %1
  store i32 0, ptr %2, align 4, !dbg !452
  br label %32, !dbg !452

15:                                               ; preds = %1
  call void @llvm.dbg.declare(metadata ptr %5, metadata !453, metadata !DIExpression()), !dbg !455
  %16 = load ptr, ptr %3, align 8, !dbg !455
  %17 = getelementptr inbounds %struct.qspinlock, ptr %16, i32 0, i32 0, !dbg !455
  %18 = getelementptr inbounds %struct.atomic_t, ptr %17, i32 0, i32 0, !dbg !455
  %19 = load i32, ptr %4, align 4, !dbg !455
  %20 = sext i32 %19 to i64, !dbg !455
  %21 = call i64 @__LKMM_cmpxchg(ptr noundef %18, i64 noundef 4, i64 noundef %20, i64 noundef 1, i32 noundef 1, i32 noundef 1), !dbg !455
  %22 = trunc i64 %21 to i32, !dbg !455
  store i32 %22, ptr %5, align 4, !dbg !455
  %23 = load i32, ptr %5, align 4, !dbg !455
  %24 = load i32, ptr %4, align 4, !dbg !455
  %25 = icmp eq i32 %23, %24, !dbg !455
  br i1 %25, label %26, label %27, !dbg !455

26:                                               ; preds = %15
  br label %29, !dbg !455

27:                                               ; preds = %15
  %28 = load i32, ptr %5, align 4, !dbg !455
  store i32 %28, ptr %4, align 4, !dbg !455
  br label %29, !dbg !455

29:                                               ; preds = %27, %26
  %30 = phi i32 [ 1, %26 ], [ 0, %27 ], !dbg !455
  store i32 %30, ptr %6, align 4, !dbg !455
  %31 = load i32, ptr %6, align 4, !dbg !455
  store i32 %31, ptr %2, align 4, !dbg !456
  br label %32, !dbg !456

32:                                               ; preds = %29, %14
  %33 = load i32, ptr %2, align 4, !dbg !457
  ret i32 %33, !dbg !457
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define internal ptr @grab_mcs_node(ptr noundef %0, i32 noundef %1) #0 !dbg !458 {
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  store ptr %0, ptr %3, align 8
  call void @llvm.dbg.declare(metadata ptr %3, metadata !461, metadata !DIExpression()), !dbg !462
  store i32 %1, ptr %4, align 4
  call void @llvm.dbg.declare(metadata ptr %4, metadata !463, metadata !DIExpression()), !dbg !464
  %5 = load ptr, ptr %3, align 8, !dbg !465
  %6 = load i32, ptr %4, align 4, !dbg !466
  %7 = sext i32 %6 to i64, !dbg !467
  %8 = getelementptr inbounds %struct.qnode, ptr %5, i64 %7, !dbg !467
  %9 = getelementptr inbounds %struct.qnode, ptr %8, i32 0, i32 0, !dbg !468
  ret ptr %9, !dbg !469
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define internal void @__pv_init_node(ptr noundef %0) #0 !dbg !470 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  call void @llvm.dbg.declare(metadata ptr %2, metadata !473, metadata !DIExpression()), !dbg !474
  ret void, !dbg !475
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define internal i32 @xchg_tail(ptr noundef %0, i32 noundef %1) #0 !dbg !476 {
  %3 = alloca ptr, align 8
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  store ptr %0, ptr %3, align 8
  call void @llvm.dbg.declare(metadata ptr %3, metadata !479, metadata !DIExpression()), !dbg !480
  store i32 %1, ptr %4, align 4
  call void @llvm.dbg.declare(metadata ptr %4, metadata !481, metadata !DIExpression()), !dbg !482
  call void @llvm.dbg.declare(metadata ptr %5, metadata !483, metadata !DIExpression()), !dbg !484
  call void @llvm.dbg.declare(metadata ptr %6, metadata !485, metadata !DIExpression()), !dbg !486
  br label %9, !dbg !487

9:                                                ; preds = %35, %2
  %10 = load ptr, ptr %3, align 8, !dbg !488
  %11 = getelementptr inbounds %struct.qspinlock, ptr %10, i32 0, i32 0, !dbg !488
  %12 = getelementptr inbounds %struct.atomic_t, ptr %11, i32 0, i32 0, !dbg !488
  %13 = call i64 @__LKMM_load(ptr noundef %12, i64 noundef 4, i32 noundef 0), !dbg !488
  %14 = trunc i64 %13 to i32, !dbg !488
  store i32 %14, ptr %5, align 4, !dbg !490
  %15 = load i32, ptr %5, align 4, !dbg !491
  %16 = and i32 %15, 65535, !dbg !492
  %17 = load i32, ptr %4, align 4, !dbg !493
  %18 = or i32 %16, %17, !dbg !494
  store i32 %18, ptr %6, align 4, !dbg !495
  br label %19, !dbg !496

19:                                               ; preds = %9
  call void @llvm.dbg.declare(metadata ptr %7, metadata !497, metadata !DIExpression()), !dbg !499
  %20 = load ptr, ptr %3, align 8, !dbg !499
  %21 = getelementptr inbounds %struct.qspinlock, ptr %20, i32 0, i32 0, !dbg !499
  %22 = getelementptr inbounds %struct.atomic_t, ptr %21, i32 0, i32 0, !dbg !499
  %23 = load i32, ptr %5, align 4, !dbg !499
  %24 = sext i32 %23 to i64, !dbg !499
  %25 = load i32, ptr %6, align 4, !dbg !499
  %26 = zext i32 %25 to i64, !dbg !499
  %27 = call i64 @__LKMM_cmpxchg(ptr noundef %22, i64 noundef 4, i64 noundef %24, i64 noundef %26, i32 noundef 0, i32 noundef 0), !dbg !499
  %28 = trunc i64 %27 to i32, !dbg !499
  store i32 %28, ptr %7, align 4, !dbg !499
  %29 = load i32, ptr %7, align 4, !dbg !499
  %30 = load i32, ptr %5, align 4, !dbg !499
  %31 = icmp eq i32 %29, %30, !dbg !499
  br i1 %31, label %32, label %33, !dbg !499

32:                                               ; preds = %19
  br label %35, !dbg !499

33:                                               ; preds = %19
  %34 = load i32, ptr %7, align 4, !dbg !499
  store i32 %34, ptr %5, align 4, !dbg !499
  br label %35, !dbg !499

35:                                               ; preds = %33, %32
  %36 = phi i32 [ 1, %32 ], [ 0, %33 ], !dbg !499
  store i32 %36, ptr %8, align 4, !dbg !499
  %37 = load i32, ptr %8, align 4, !dbg !499
  %38 = icmp ne i32 %37, 0, !dbg !500
  %39 = xor i1 %38, true, !dbg !500
  br i1 %39, label %9, label %40, !dbg !496, !llvm.loop !501

40:                                               ; preds = %35
  %41 = load i32, ptr %5, align 4, !dbg !503
  ret i32 %41, !dbg !504
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define internal ptr @decode_tail(i32 noundef %0, ptr noundef %1) #0 !dbg !505 {
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store i32 %0, ptr %3, align 4
  call void @llvm.dbg.declare(metadata ptr %3, metadata !508, metadata !DIExpression()), !dbg !509
  store ptr %1, ptr %4, align 8
  call void @llvm.dbg.declare(metadata ptr %4, metadata !510, metadata !DIExpression()), !dbg !511
  call void @llvm.dbg.declare(metadata ptr %5, metadata !512, metadata !DIExpression()), !dbg !513
  %7 = load i32, ptr %3, align 4, !dbg !514
  %8 = lshr i32 %7, 18, !dbg !515
  %9 = sub i32 %8, 1, !dbg !516
  store i32 %9, ptr %5, align 4, !dbg !513
  call void @llvm.dbg.declare(metadata ptr %6, metadata !517, metadata !DIExpression()), !dbg !518
  %10 = load i32, ptr %3, align 4, !dbg !519
  %11 = and i32 %10, 196608, !dbg !520
  %12 = lshr i32 %11, 16, !dbg !521
  store i32 %12, ptr %6, align 4, !dbg !518
  %13 = load i32, ptr %5, align 4, !dbg !522
  %14 = call ptr @get_node(i32 noundef %13), !dbg !522
  ret ptr %14, !dbg !523
}

declare void @__LKMM_store(ptr noundef, i64 noundef, i64 noundef, i32 noundef) #2

; Function Attrs: noinline nounwind ssp uwtable(sync)
define internal void @__pv_wait_node(ptr noundef %0, ptr noundef %1) #0 !dbg !524 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  call void @llvm.dbg.declare(metadata ptr %3, metadata !527, metadata !DIExpression()), !dbg !528
  store ptr %1, ptr %4, align 8
  call void @llvm.dbg.declare(metadata ptr %4, metadata !529, metadata !DIExpression()), !dbg !530
  ret void, !dbg !531
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define internal i32 @__pv_wait_head_or_lock(ptr noundef %0, ptr noundef %1) #0 !dbg !532 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  call void @llvm.dbg.declare(metadata ptr %3, metadata !535, metadata !DIExpression()), !dbg !536
  store ptr %1, ptr %4, align 8
  call void @llvm.dbg.declare(metadata ptr %4, metadata !537, metadata !DIExpression()), !dbg !538
  ret i32 0, !dbg !539
}

declare i64 @__LKMM_cmpxchg(ptr noundef, i64 noundef, i64 noundef, i64 noundef, i32 noundef, i32 noundef) #2

; Function Attrs: noinline nounwind ssp uwtable(sync)
define internal void @set_locked(ptr noundef %0) #0 !dbg !540 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  call void @llvm.dbg.declare(metadata ptr %2, metadata !541, metadata !DIExpression()), !dbg !542
  %3 = load ptr, ptr %2, align 8, !dbg !543
  %4 = getelementptr inbounds %struct.qspinlock, ptr %3, i32 0, i32 0, !dbg !543
  %5 = getelementptr inbounds %struct.atomic_t, ptr %4, i32 0, i32 0, !dbg !543
  call void @__LKMM_atomic_op(ptr noundef %5, i64 noundef 4, i64 noundef 1, i32 noundef 3), !dbg !543
  ret void, !dbg !544
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define internal void @__pv_kick_node(ptr noundef %0, ptr noundef %1) #0 !dbg !545 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  call void @llvm.dbg.declare(metadata ptr %3, metadata !548, metadata !DIExpression()), !dbg !549
  store ptr %1, ptr %4, align 8
  call void @llvm.dbg.declare(metadata ptr %4, metadata !550, metadata !DIExpression()), !dbg !551
  ret void, !dbg !552
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @main() #0 !dbg !553 {
  %1 = alloca i32, align 4
  %2 = alloca [4 x ptr], align 8
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  call void @llvm.dbg.declare(metadata ptr %2, metadata !556, metadata !DIExpression()), !dbg !581
  call void @llvm.dbg.declare(metadata ptr %3, metadata !582, metadata !DIExpression()), !dbg !584
  store i32 0, ptr %3, align 4, !dbg !584
  br label %5, !dbg !585

5:                                                ; preds = %16, %0
  %6 = load i32, ptr %3, align 4, !dbg !586
  %7 = icmp slt i32 %6, 4, !dbg !588
  br i1 %7, label %8, label %19, !dbg !589

8:                                                ; preds = %5
  %9 = load i32, ptr %3, align 4, !dbg !590
  %10 = sext i32 %9 to i64, !dbg !591
  %11 = getelementptr inbounds [4 x ptr], ptr %2, i64 0, i64 %10, !dbg !591
  %12 = load i32, ptr %3, align 4, !dbg !592
  %13 = sext i32 %12 to i64, !dbg !593
  %14 = inttoptr i64 %13 to ptr, !dbg !593
  %15 = call i32 @pthread_create(ptr noundef %11, ptr noundef null, ptr noundef @run, ptr noundef %14), !dbg !594
  br label %16, !dbg !594

16:                                               ; preds = %8
  %17 = load i32, ptr %3, align 4, !dbg !595
  %18 = add nsw i32 %17, 1, !dbg !595
  store i32 %18, ptr %3, align 4, !dbg !595
  br label %5, !dbg !596, !llvm.loop !597

19:                                               ; preds = %5
  call void @llvm.dbg.declare(metadata ptr %4, metadata !599, metadata !DIExpression()), !dbg !601
  store i32 0, ptr %4, align 4, !dbg !601
  br label %20, !dbg !602

20:                                               ; preds = %29, %19
  %21 = load i32, ptr %4, align 4, !dbg !603
  %22 = icmp slt i32 %21, 4, !dbg !605
  br i1 %22, label %23, label %32, !dbg !606

23:                                               ; preds = %20
  %24 = load i32, ptr %4, align 4, !dbg !607
  %25 = sext i32 %24 to i64, !dbg !608
  %26 = getelementptr inbounds [4 x ptr], ptr %2, i64 0, i64 %25, !dbg !608
  %27 = load ptr, ptr %26, align 8, !dbg !608
  %28 = call i32 @"\01_pthread_join"(ptr noundef %27, ptr noundef null), !dbg !609
  br label %29, !dbg !609

29:                                               ; preds = %23
  %30 = load i32, ptr %4, align 4, !dbg !610
  %31 = add nsw i32 %30, 1, !dbg !610
  store i32 %31, ptr %4, align 4, !dbg !610
  br label %20, !dbg !611, !llvm.loop !612

32:                                               ; preds = %20
  %33 = load i32, ptr @x, align 4, !dbg !614
  %34 = load i32, ptr @y, align 4, !dbg !614
  %35 = icmp eq i32 %33, %34, !dbg !614
  %36 = xor i1 %35, true, !dbg !614
  %37 = zext i1 %36 to i32, !dbg !614
  %38 = sext i32 %37 to i64, !dbg !614
  %39 = icmp ne i64 %38, 0, !dbg !614
  br i1 %39, label %40, label %42, !dbg !614

40:                                               ; preds = %32
  call void @__assert_rtn(ptr noundef @__func__.main, ptr noundef @.str, i32 noundef 119, ptr noundef @.str.1) #4, !dbg !614
  unreachable, !dbg !614

41:                                               ; No predecessors!
  br label %43, !dbg !614

42:                                               ; preds = %32
  br label %43, !dbg !614

43:                                               ; preds = %42, %41
  ret i32 0, !dbg !615
}

declare i32 @pthread_create(ptr noundef, ptr noundef, ptr noundef, ptr noundef) #2

; Function Attrs: noinline nounwind ssp uwtable(sync)
define internal ptr @run(ptr noundef %0) #0 !dbg !616 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  call void @llvm.dbg.declare(metadata ptr %2, metadata !619, metadata !DIExpression()), !dbg !620
  %3 = load ptr, ptr %2, align 8, !dbg !621
  %4 = ptrtoint ptr %3 to i64, !dbg !622
  %5 = trunc i64 %4 to i32, !dbg !622
  %6 = call align 4 ptr @llvm.threadlocal.address.p0(ptr align 4 @tid), !dbg !623
  store i32 %5, ptr %6, align 4, !dbg !624
  call void @queued_spin_lock(ptr noundef @lock), !dbg !625
  %7 = load i32, ptr @x, align 4, !dbg !626
  %8 = add nsw i32 %7, 1, !dbg !627
  store i32 %8, ptr @x, align 4, !dbg !628
  %9 = load i32, ptr @y, align 4, !dbg !629
  %10 = add nsw i32 %9, 1, !dbg !630
  store i32 %10, ptr @y, align 4, !dbg !631
  call void @queued_spin_unlock(ptr noundef @lock), !dbg !632
  ret ptr null, !dbg !633
}

declare i32 @"\01_pthread_join"(ptr noundef, ptr noundef) #2

; Function Attrs: cold noreturn
declare void @__assert_rtn(ptr noundef, ptr noundef, i32 noundef, ptr noundef) #3

declare i64 @__LKMM_atomic_fetch_op(ptr noundef, i64 noundef, i64 noundef, i32 noundef, i32 noundef) #2

declare void @__LKMM_atomic_op(ptr noundef, i64 noundef, i64 noundef, i32 noundef) #2

; Function Attrs: noinline nounwind ssp uwtable(sync)
define internal void @queued_spin_lock(ptr noundef %0) #0 !dbg !634 {
  %2 = alloca ptr, align 8
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  store ptr %0, ptr %2, align 8
  call void @llvm.dbg.declare(metadata ptr %2, metadata !635, metadata !DIExpression()), !dbg !636
  call void @llvm.dbg.declare(metadata ptr %3, metadata !637, metadata !DIExpression()), !dbg !638
  store i32 0, ptr %3, align 4, !dbg !638
  call void @llvm.dbg.declare(metadata ptr %4, metadata !639, metadata !DIExpression()), !dbg !642
  %6 = load ptr, ptr %2, align 8, !dbg !642
  %7 = getelementptr inbounds %struct.qspinlock, ptr %6, i32 0, i32 0, !dbg !642
  %8 = getelementptr inbounds %struct.atomic_t, ptr %7, i32 0, i32 0, !dbg !642
  %9 = load i32, ptr %3, align 4, !dbg !642
  %10 = sext i32 %9 to i64, !dbg !642
  %11 = call i64 @__LKMM_cmpxchg(ptr noundef %8, i64 noundef 4, i64 noundef %10, i64 noundef 1, i32 noundef 1, i32 noundef 1), !dbg !642
  %12 = trunc i64 %11 to i32, !dbg !642
  store i32 %12, ptr %4, align 4, !dbg !642
  %13 = load i32, ptr %4, align 4, !dbg !642
  %14 = load i32, ptr %3, align 4, !dbg !642
  %15 = icmp eq i32 %13, %14, !dbg !642
  br i1 %15, label %16, label %17, !dbg !642

16:                                               ; preds = %1
  br label %19, !dbg !642

17:                                               ; preds = %1
  %18 = load i32, ptr %4, align 4, !dbg !642
  store i32 %18, ptr %3, align 4, !dbg !642
  br label %19, !dbg !642

19:                                               ; preds = %17, %16
  %20 = phi i32 [ 1, %16 ], [ 0, %17 ], !dbg !642
  store i32 %20, ptr %5, align 4, !dbg !642
  %21 = load i32, ptr %5, align 4, !dbg !642
  %22 = icmp ne i32 %21, 0, !dbg !643
  br i1 %22, label %23, label %24, !dbg !644

23:                                               ; preds = %19
  br label %27, !dbg !645

24:                                               ; preds = %19
  %25 = load ptr, ptr %2, align 8, !dbg !646
  %26 = load i32, ptr %3, align 4, !dbg !647
  call void @queued_spin_lock_slowpath(ptr noundef %25, i32 noundef %26), !dbg !648
  br label %27, !dbg !649

27:                                               ; preds = %24, %23
  ret void, !dbg !649
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define internal void @queued_spin_unlock(ptr noundef %0) #0 !dbg !650 {
  %2 = alloca ptr, align 8
  store ptr %0, ptr %2, align 8
  call void @llvm.dbg.declare(metadata ptr %2, metadata !651, metadata !DIExpression()), !dbg !652
  %3 = load ptr, ptr %2, align 8, !dbg !653
  %4 = getelementptr inbounds %struct.qspinlock, ptr %3, i32 0, i32 0, !dbg !653
  %5 = getelementptr inbounds %struct.atomic_t, ptr %4, i32 0, i32 0, !dbg !653
  %6 = call i64 @__LKMM_atomic_fetch_op(ptr noundef %5, i64 noundef 4, i64 noundef 1, i32 noundef 2, i32 noundef 1), !dbg !653
  %7 = trunc i64 %6 to i32, !dbg !653
  ret void, !dbg !654
}

attributes #0 = { noinline nounwind ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #2 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #3 = { cold noreturn "disable-tail-calls"="true" "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #4 = { cold noreturn }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!114, !115, !116, !117, !118, !119}
!llvm.ident = !{!120}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "tid", scope: !2, file: !54, line: 45, type: !29, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C11, file: !3, producer: "Homebrew clang version 17.0.6", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !28, globals: !51, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/Library/Developer/CommandLineTools/SDKs/MacOSX15.sdk", sdk: "MacOSX15.sdk")
!3 = !DIFile(filename: "/Users/thomashaas/ExternalTools/cna-verification/client-code.c", directory: "/Users/thomashaas/ExternalTools/cna-verification")
!4 = !{!5, !22}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "__LKMM_memory_order", file: !6, line: 3, baseType: !7, size: 32, elements: !8)
!6 = !DIFile(filename: "IdeaProjects/Dat3M/include/lkmm.h", directory: "/Users/thomashaas")
!7 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!8 = !{!9, !10, !11, !12, !13, !14, !15, !16, !17, !18, !19, !20, !21}
!9 = !DIEnumerator(name: "__LKMM_once", value: 0)
!10 = !DIEnumerator(name: "__LKMM_acquire", value: 1)
!11 = !DIEnumerator(name: "__LKMM_release", value: 2)
!12 = !DIEnumerator(name: "__LKMM_mb", value: 3)
!13 = !DIEnumerator(name: "__LKMM_wmb", value: 4)
!14 = !DIEnumerator(name: "__LKMM_rmb", value: 5)
!15 = !DIEnumerator(name: "__LKMM_rcu_lock", value: 6)
!16 = !DIEnumerator(name: "__LKMM_rcu_unlock", value: 7)
!17 = !DIEnumerator(name: "__LKMM_rcu_sync", value: 8)
!18 = !DIEnumerator(name: "__LKMM_before_atomic", value: 9)
!19 = !DIEnumerator(name: "__LKMM_after_atomic", value: 10)
!20 = !DIEnumerator(name: "__LKMM_after_spinlock", value: 11)
!21 = !DIEnumerator(name: "__LKMM_barrier", value: 12)
!22 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "__LKMM_operation", file: !6, line: 19, baseType: !7, size: 32, elements: !23)
!23 = !{!24, !25, !26, !27}
!24 = !DIEnumerator(name: "__LKMM_op_add", value: 0)
!25 = !DIEnumerator(name: "__LKMM_op_sub", value: 1)
!26 = !DIEnumerator(name: "__LKMM_op_and", value: 2)
!27 = !DIEnumerator(name: "__LKMM_op_or", value: 3)
!28 = !{!29, !30, !34, !41, !42, !47}
!29 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!30 = !DIDerivedType(tag: DW_TAG_typedef, name: "__LKMM_int_t", file: !6, line: 27, baseType: !31)
!31 = !DIDerivedType(tag: DW_TAG_typedef, name: "intmax_t", file: !32, line: 32, baseType: !33)
!32 = !DIFile(filename: "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/_types/_intmax_t.h", directory: "")
!33 = !DIBasicType(name: "long", size: 64, encoding: DW_ATE_signed)
!34 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !35, size: 64)
!35 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "mcs_spinlock", file: !36, line: 4, size: 128, elements: !37)
!36 = !DIFile(filename: "include/asm-generic/mcs_spinlock.h", directory: "/Users/thomashaas/ExternalTools/cna-verification")
!37 = !{!38, !39, !40}
!38 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !35, file: !36, line: 5, baseType: !34, size: 64)
!39 = !DIDerivedType(tag: DW_TAG_member, name: "locked", scope: !35, file: !36, line: 6, baseType: !29, size: 32, offset: 64)
!40 = !DIDerivedType(tag: DW_TAG_member, name: "count", scope: !35, file: !36, line: 7, baseType: !29, size: 32, offset: 96)
!41 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!42 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !43, size: 64)
!43 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "qnode", file: !44, line: 40, size: 128, elements: !45)
!44 = !DIFile(filename: "kernel/locking/qspinlock.h", directory: "/Users/thomashaas/ExternalTools/cna-verification")
!45 = !{!46}
!46 = !DIDerivedType(tag: DW_TAG_member, name: "mcs", scope: !43, file: !44, line: 41, baseType: !35, size: 128)
!47 = !DIDerivedType(tag: DW_TAG_typedef, name: "intptr_t", file: !48, line: 32, baseType: !49)
!48 = !DIFile(filename: "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/sys/_types/_intptr_t.h", directory: "")
!49 = !DIDerivedType(tag: DW_TAG_typedef, name: "__darwin_intptr_t", file: !50, line: 40, baseType: !33)
!50 = !DIFile(filename: "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/arm/_types.h", directory: "")
!51 = !{!52, !60, !65, !0, !70, !77, !110, !112}
!52 = !DIGlobalVariableExpression(var: !53, expr: !DIExpression())
!53 = distinct !DIGlobalVariable(scope: null, file: !54, line: 119, type: !55, isLocal: true, isDefinition: true)
!54 = !DIFile(filename: "client-code.c", directory: "/Users/thomashaas/ExternalTools/cna-verification")
!55 = !DICompositeType(tag: DW_TAG_array_type, baseType: !56, size: 40, elements: !58)
!56 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !57)
!57 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!58 = !{!59}
!59 = !DISubrange(count: 5)
!60 = !DIGlobalVariableExpression(var: !61, expr: !DIExpression())
!61 = distinct !DIGlobalVariable(scope: null, file: !54, line: 119, type: !62, isLocal: true, isDefinition: true)
!62 = !DICompositeType(tag: DW_TAG_array_type, baseType: !57, size: 112, elements: !63)
!63 = !{!64}
!64 = !DISubrange(count: 14)
!65 = !DIGlobalVariableExpression(var: !66, expr: !DIExpression())
!66 = distinct !DIGlobalVariable(scope: null, file: !54, line: 119, type: !67, isLocal: true, isDefinition: true)
!67 = !DICompositeType(tag: DW_TAG_array_type, baseType: !57, size: 56, elements: !68)
!68 = !{!69}
!69 = !DISubrange(count: 7)
!70 = !DIGlobalVariableExpression(var: !71, expr: !DIExpression())
!71 = distinct !DIGlobalVariable(name: "qnodes", scope: !2, file: !72, line: 80, type: !73, isLocal: true, isDefinition: true)
!72 = !DIFile(filename: "kernel/locking/qspinlock.c", directory: "/Users/thomashaas/ExternalTools/cna-verification")
!73 = !DICompositeType(tag: DW_TAG_array_type, baseType: !43, size: 512, elements: !74)
!74 = !{!75, !76}
!75 = !DISubrange(count: 1)
!76 = !DISubrange(count: 4)
!77 = !DIGlobalVariableExpression(var: !78, expr: !DIExpression())
!78 = distinct !DIGlobalVariable(name: "lock", scope: !2, file: !54, line: 75, type: !79, isLocal: false, isDefinition: true)
!79 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "qspinlock", file: !80, line: 14, size: 32, elements: !81)
!80 = !DIFile(filename: "include/asm-generic/qspinlock_types.h", directory: "/Users/thomashaas/ExternalTools/cna-verification")
!81 = !{!82}
!82 = !DIDerivedType(tag: DW_TAG_member, scope: !79, file: !80, line: 15, baseType: !83, size: 32)
!83 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !79, file: !80, line: 15, size: 32, elements: !84)
!84 = !{!85, !90, !98}
!85 = !DIDerivedType(tag: DW_TAG_member, name: "val", scope: !83, file: !80, line: 16, baseType: !86, size: 32)
!86 = !DIDerivedType(tag: DW_TAG_typedef, name: "atomic_t", file: !6, line: 108, baseType: !87)
!87 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !6, line: 106, size: 32, elements: !88)
!88 = !{!89}
!89 = !DIDerivedType(tag: DW_TAG_member, name: "counter", scope: !87, file: !6, line: 107, baseType: !29, size: 32)
!90 = !DIDerivedType(tag: DW_TAG_member, scope: !83, file: !80, line: 33, baseType: !91, size: 32)
!91 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !83, file: !80, line: 33, size: 32, elements: !92)
!92 = !{!93, !97}
!93 = !DIDerivedType(tag: DW_TAG_member, name: "tail", scope: !91, file: !80, line: 34, baseType: !94, size: 16)
!94 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !95, line: 31, baseType: !96)
!95 = !DIFile(filename: "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/_types/_uint16_t.h", directory: "")
!96 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!97 = !DIDerivedType(tag: DW_TAG_member, name: "locked_pending", scope: !91, file: !80, line: 35, baseType: !94, size: 16, offset: 16)
!98 = !DIDerivedType(tag: DW_TAG_member, scope: !83, file: !80, line: 37, baseType: !99, size: 32)
!99 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !83, file: !80, line: 37, size: 32, elements: !100)
!100 = !{!101, !108, !109}
!101 = !DIDerivedType(tag: DW_TAG_member, name: "reserved", scope: !99, file: !80, line: 38, baseType: !102, size: 16)
!102 = !DICompositeType(tag: DW_TAG_array_type, baseType: !103, size: 16, elements: !106)
!103 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !104, line: 31, baseType: !105)
!104 = !DIFile(filename: "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/_types/_uint8_t.h", directory: "")
!105 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!106 = !{!107}
!107 = !DISubrange(count: 2)
!108 = !DIDerivedType(tag: DW_TAG_member, name: "pending", scope: !99, file: !80, line: 39, baseType: !103, size: 8, offset: 16)
!109 = !DIDerivedType(tag: DW_TAG_member, name: "locked", scope: !99, file: !80, line: 40, baseType: !103, size: 8, offset: 24)
!110 = !DIGlobalVariableExpression(var: !111, expr: !DIExpression())
!111 = distinct !DIGlobalVariable(name: "x", scope: !2, file: !54, line: 92, type: !29, isLocal: true, isDefinition: true)
!112 = !DIGlobalVariableExpression(var: !113, expr: !DIExpression())
!113 = distinct !DIGlobalVariable(name: "y", scope: !2, file: !54, line: 92, type: !29, isLocal: true, isDefinition: true)
!114 = !{i32 7, !"Dwarf Version", i32 4}
!115 = !{i32 2, !"Debug Info Version", i32 3}
!116 = !{i32 1, !"wchar_size", i32 4}
!117 = !{i32 8, !"PIC Level", i32 2}
!118 = !{i32 7, !"uwtable", i32 1}
!119 = !{i32 7, !"frame-pointer", i32 1}
!120 = !{!"Homebrew clang version 17.0.6"}
!121 = distinct !DISubprogram(name: "queued_spin_lock_slowpath", scope: !72, file: !72, line: 130, type: !122, scopeLine: 131, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !127)
!122 = !DISubroutineType(types: !123)
!123 = !{null, !124, !125}
!124 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !79, size: 64)
!125 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !126, line: 31, baseType: !7)
!126 = !DIFile(filename: "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/_types/_uint32_t.h", directory: "")
!127 = !{}
!128 = !DILocalVariable(name: "lock", arg: 1, scope: !121, file: !72, line: 130, type: !124)
!129 = !DILocation(line: 130, column: 61, scope: !121)
!130 = !DILocalVariable(name: "val", arg: 2, scope: !121, file: !72, line: 130, type: !125)
!131 = !DILocation(line: 130, column: 71, scope: !121)
!132 = !DILocalVariable(name: "prev", scope: !121, file: !72, line: 132, type: !34)
!133 = !DILocation(line: 132, column: 23, scope: !121)
!134 = !DILocalVariable(name: "next", scope: !121, file: !72, line: 132, type: !34)
!135 = !DILocation(line: 132, column: 30, scope: !121)
!136 = !DILocalVariable(name: "node", scope: !121, file: !72, line: 132, type: !34)
!137 = !DILocation(line: 132, column: 37, scope: !121)
!138 = !DILocalVariable(name: "old", scope: !121, file: !72, line: 133, type: !125)
!139 = !DILocation(line: 133, column: 6, scope: !121)
!140 = !DILocalVariable(name: "tail", scope: !121, file: !72, line: 133, type: !125)
!141 = !DILocation(line: 133, column: 11, scope: !121)
!142 = !DILocalVariable(name: "idx", scope: !121, file: !72, line: 134, type: !29)
!143 = !DILocation(line: 134, column: 6, scope: !121)
!144 = !DILocation(line: 141, column: 21, scope: !145)
!145 = distinct !DILexicalBlock(scope: !121, file: !72, line: 141, column: 6)
!146 = !DILocation(line: 141, column: 6, scope: !145)
!147 = !DILocation(line: 141, column: 6, scope: !121)
!148 = !DILocation(line: 142, column: 3, scope: !145)
!149 = !DILocation(line: 150, column: 6, scope: !150)
!150 = distinct !DILexicalBlock(scope: !121, file: !72, line: 150, column: 6)
!151 = !DILocation(line: 150, column: 10, scope: !150)
!152 = !DILocation(line: 150, column: 6, scope: !121)
!153 = !DILocalVariable(name: "cnt", scope: !154, file: !72, line: 151, type: !29)
!154 = distinct !DILexicalBlock(scope: !150, file: !72, line: 150, column: 29)
!155 = !DILocation(line: 151, column: 7, scope: !154)
!156 = !DILocalVariable(name: "__PTR", scope: !157, file: !72, line: 152, type: !158)
!157 = distinct !DILexicalBlock(scope: !154, file: !72, line: 152, column: 9)
!158 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !29, size: 64)
!159 = !DILocation(line: 152, column: 9, scope: !157)
!160 = !DILocalVariable(name: "VAL", scope: !157, file: !72, line: 152, type: !29)
!161 = !DILocation(line: 152, column: 9, scope: !162)
!162 = distinct !DILexicalBlock(scope: !163, file: !72, line: 152, column: 9)
!163 = distinct !DILexicalBlock(scope: !164, file: !72, line: 152, column: 9)
!164 = distinct !DILexicalBlock(scope: !157, file: !72, line: 152, column: 9)
!165 = !DILocation(line: 152, column: 9, scope: !166)
!166 = distinct !DILexicalBlock(scope: !162, file: !72, line: 152, column: 9)
!167 = !DILocation(line: 152, column: 9, scope: !168)
!168 = distinct !DILexicalBlock(scope: !162, file: !72, line: 152, column: 9)
!169 = !DILocation(line: 152, column: 9, scope: !163)
!170 = distinct !{!170, !171, !171}
!171 = !DILocation(line: 152, column: 9, scope: !164)
!172 = !DILocation(line: 152, column: 7, scope: !154)
!173 = !DILocation(line: 154, column: 2, scope: !154)
!174 = !DILocation(line: 159, column: 6, scope: !175)
!175 = distinct !DILexicalBlock(scope: !121, file: !72, line: 159, column: 6)
!176 = !DILocation(line: 159, column: 10, scope: !175)
!177 = !DILocation(line: 159, column: 6, scope: !121)
!178 = !DILocation(line: 160, column: 3, scope: !175)
!179 = !DILocation(line: 167, column: 41, scope: !121)
!180 = !DILocation(line: 167, column: 8, scope: !121)
!181 = !DILocation(line: 167, column: 6, scope: !121)
!182 = !DILocation(line: 176, column: 6, scope: !183)
!183 = distinct !DILexicalBlock(scope: !121, file: !72, line: 176, column: 6)
!184 = !DILocation(line: 176, column: 6, scope: !121)
!185 = !DILocation(line: 179, column: 9, scope: !186)
!186 = distinct !DILexicalBlock(scope: !187, file: !72, line: 179, column: 7)
!187 = distinct !DILexicalBlock(scope: !183, file: !72, line: 176, column: 39)
!188 = !DILocation(line: 179, column: 13, scope: !186)
!189 = !DILocation(line: 179, column: 7, scope: !187)
!190 = !DILocation(line: 180, column: 18, scope: !186)
!191 = !DILocation(line: 180, column: 4, scope: !186)
!192 = !DILocation(line: 182, column: 3, scope: !187)
!193 = !DILocation(line: 196, column: 6, scope: !194)
!194 = distinct !DILexicalBlock(scope: !121, file: !72, line: 196, column: 6)
!195 = !DILocation(line: 196, column: 10, scope: !194)
!196 = !DILocation(line: 196, column: 6, scope: !121)
!197 = !DILocalVariable(name: "_val", scope: !198, file: !72, line: 197, type: !29)
!198 = distinct !DILexicalBlock(scope: !194, file: !72, line: 197, column: 3)
!199 = !DILocation(line: 197, column: 3, scope: !198)
!200 = !DILocalVariable(name: "__PTR", scope: !201, file: !72, line: 197, type: !158)
!201 = distinct !DILexicalBlock(scope: !198, file: !72, line: 197, column: 3)
!202 = !DILocation(line: 197, column: 3, scope: !201)
!203 = !DILocalVariable(name: "VAL", scope: !201, file: !72, line: 197, type: !29)
!204 = !DILocation(line: 197, column: 3, scope: !205)
!205 = distinct !DILexicalBlock(scope: !206, file: !72, line: 197, column: 3)
!206 = distinct !DILexicalBlock(scope: !207, file: !72, line: 197, column: 3)
!207 = distinct !DILexicalBlock(scope: !201, file: !72, line: 197, column: 3)
!208 = !DILocation(line: 197, column: 3, scope: !209)
!209 = distinct !DILexicalBlock(scope: !205, file: !72, line: 197, column: 3)
!210 = !DILocation(line: 197, column: 3, scope: !211)
!211 = distinct !DILexicalBlock(scope: !205, file: !72, line: 197, column: 3)
!212 = !DILocation(line: 197, column: 3, scope: !206)
!213 = distinct !{!213, !214, !214}
!214 = !DILocation(line: 197, column: 3, scope: !207)
!215 = !DILocation(line: 197, column: 3, scope: !194)
!216 = !DILocation(line: 204, column: 27, scope: !121)
!217 = !DILocation(line: 204, column: 2, scope: !121)
!218 = !DILocation(line: 206, column: 2, scope: !121)
!219 = !DILabel(scope: !121, name: "queue", file: !72, line: 212)
!220 = !DILocation(line: 212, column: 1, scope: !121)
!221 = !DILabel(scope: !121, name: "pv_queue", file: !72, line: 214)
!222 = !DILocation(line: 214, column: 1, scope: !121)
!223 = !DILocation(line: 215, column: 9, scope: !121)
!224 = !DILocation(line: 215, column: 7, scope: !121)
!225 = !DILocation(line: 216, column: 8, scope: !121)
!226 = !DILocation(line: 216, column: 14, scope: !121)
!227 = !DILocation(line: 216, column: 19, scope: !121)
!228 = !DILocation(line: 216, column: 6, scope: !121)
!229 = !DILocation(line: 217, column: 21, scope: !121)
!230 = !DILocation(line: 217, column: 41, scope: !121)
!231 = !DILocation(line: 217, column: 9, scope: !121)
!232 = !DILocation(line: 217, column: 7, scope: !121)
!233 = !DILocation(line: 230, column: 6, scope: !234)
!234 = distinct !DILexicalBlock(scope: !121, file: !72, line: 230, column: 6)
!235 = !DILocation(line: 230, column: 6, scope: !121)
!236 = !DILocation(line: 232, column: 3, scope: !237)
!237 = distinct !DILexicalBlock(scope: !234, file: !72, line: 230, column: 37)
!238 = !DILocation(line: 232, column: 31, scope: !237)
!239 = !DILocation(line: 232, column: 11, scope: !237)
!240 = !DILocation(line: 232, column: 10, scope: !237)
!241 = !DILocation(line: 233, column: 4, scope: !237)
!242 = !DILocation(line: 233, column: 4, scope: !243)
!243 = distinct !DILexicalBlock(scope: !237, file: !72, line: 233, column: 4)
!244 = distinct !{!244, !236, !241, !245}
!245 = !{!"llvm.loop.mustprogress"}
!246 = !DILocation(line: 234, column: 3, scope: !237)
!247 = !DILocation(line: 237, column: 23, scope: !121)
!248 = !DILocation(line: 237, column: 29, scope: !121)
!249 = !DILocation(line: 237, column: 9, scope: !121)
!250 = !DILocation(line: 237, column: 7, scope: !121)
!251 = !DILocation(line: 242, column: 2, scope: !121)
!252 = !DILocation(line: 242, column: 2, scope: !253)
!253 = distinct !DILexicalBlock(scope: !121, file: !72, line: 242, column: 2)
!254 = !DILocation(line: 249, column: 2, scope: !121)
!255 = !DILocation(line: 251, column: 2, scope: !121)
!256 = !DILocation(line: 251, column: 8, scope: !121)
!257 = !DILocation(line: 251, column: 15, scope: !121)
!258 = !DILocation(line: 252, column: 2, scope: !121)
!259 = !DILocation(line: 252, column: 8, scope: !121)
!260 = !DILocation(line: 252, column: 13, scope: !121)
!261 = !DILocation(line: 253, column: 15, scope: !121)
!262 = !DILocation(line: 253, column: 2, scope: !121)
!263 = !DILocation(line: 260, column: 26, scope: !264)
!264 = distinct !DILexicalBlock(scope: !121, file: !72, line: 260, column: 6)
!265 = !DILocation(line: 260, column: 6, scope: !264)
!266 = !DILocation(line: 260, column: 6, scope: !121)
!267 = !DILocation(line: 261, column: 3, scope: !264)
!268 = !DILocation(line: 268, column: 2, scope: !121)
!269 = !DILocation(line: 277, column: 18, scope: !121)
!270 = !DILocation(line: 277, column: 24, scope: !121)
!271 = !DILocation(line: 277, column: 8, scope: !121)
!272 = !DILocation(line: 277, column: 6, scope: !121)
!273 = !DILocation(line: 278, column: 7, scope: !121)
!274 = !DILocation(line: 284, column: 6, scope: !275)
!275 = distinct !DILexicalBlock(scope: !121, file: !72, line: 284, column: 6)
!276 = !DILocation(line: 284, column: 10, scope: !275)
!277 = !DILocation(line: 284, column: 6, scope: !121)
!278 = !DILocation(line: 285, column: 22, scope: !279)
!279 = distinct !DILexicalBlock(scope: !275, file: !72, line: 284, column: 26)
!280 = !DILocation(line: 285, column: 10, scope: !279)
!281 = !DILocation(line: 285, column: 8, scope: !279)
!282 = !DILocation(line: 288, column: 3, scope: !279)
!283 = !DILocation(line: 290, column: 16, scope: !279)
!284 = !DILocation(line: 290, column: 22, scope: !279)
!285 = !DILocation(line: 290, column: 3, scope: !279)
!286 = !DILocalVariable(name: "_val", scope: !287, file: !72, line: 291, type: !29)
!287 = distinct !DILexicalBlock(scope: !279, file: !72, line: 291, column: 3)
!288 = !DILocation(line: 291, column: 3, scope: !287)
!289 = !DILocalVariable(name: "__PTR", scope: !290, file: !72, line: 291, type: !158)
!290 = distinct !DILexicalBlock(scope: !287, file: !72, line: 291, column: 3)
!291 = !DILocation(line: 291, column: 3, scope: !290)
!292 = !DILocalVariable(name: "VAL", scope: !290, file: !72, line: 291, type: !29)
!293 = !DILocation(line: 291, column: 3, scope: !294)
!294 = distinct !DILexicalBlock(scope: !295, file: !72, line: 291, column: 3)
!295 = distinct !DILexicalBlock(scope: !296, file: !72, line: 291, column: 3)
!296 = distinct !DILexicalBlock(scope: !290, file: !72, line: 291, column: 3)
!297 = !DILocation(line: 291, column: 3, scope: !298)
!298 = distinct !DILexicalBlock(scope: !294, file: !72, line: 291, column: 3)
!299 = !DILocation(line: 291, column: 3, scope: !300)
!300 = distinct !DILexicalBlock(scope: !294, file: !72, line: 291, column: 3)
!301 = !DILocation(line: 291, column: 3, scope: !295)
!302 = distinct !{!302, !303, !303}
!303 = !DILocation(line: 291, column: 3, scope: !296)
!304 = !DILocation(line: 299, column: 10, scope: !279)
!305 = !DILocation(line: 299, column: 8, scope: !279)
!306 = !DILocation(line: 300, column: 7, scope: !307)
!307 = distinct !DILexicalBlock(scope: !279, file: !72, line: 300, column: 7)
!308 = !DILocation(line: 300, column: 7, scope: !279)
!309 = !DILocation(line: 301, column: 4, scope: !307)
!310 = !DILocation(line: 301, column: 4, scope: !311)
!311 = distinct !DILexicalBlock(scope: !307, file: !72, line: 301, column: 4)
!312 = !DILocation(line: 302, column: 2, scope: !279)
!313 = !DILocation(line: 325, column: 34, scope: !314)
!314 = distinct !DILexicalBlock(scope: !121, file: !72, line: 325, column: 6)
!315 = !DILocation(line: 325, column: 40, scope: !314)
!316 = !DILocation(line: 325, column: 13, scope: !314)
!317 = !DILocation(line: 325, column: 11, scope: !314)
!318 = !DILocation(line: 325, column: 6, scope: !121)
!319 = !DILocation(line: 326, column: 3, scope: !314)
!320 = !DILocalVariable(name: "_val", scope: !321, file: !72, line: 328, type: !29)
!321 = distinct !DILexicalBlock(scope: !121, file: !72, line: 328, column: 8)
!322 = !DILocation(line: 328, column: 8, scope: !321)
!323 = !DILocalVariable(name: "__PTR", scope: !324, file: !72, line: 328, type: !158)
!324 = distinct !DILexicalBlock(scope: !321, file: !72, line: 328, column: 8)
!325 = !DILocation(line: 328, column: 8, scope: !324)
!326 = !DILocalVariable(name: "VAL", scope: !324, file: !72, line: 328, type: !29)
!327 = !DILocation(line: 328, column: 8, scope: !328)
!328 = distinct !DILexicalBlock(scope: !329, file: !72, line: 328, column: 8)
!329 = distinct !DILexicalBlock(scope: !330, file: !72, line: 328, column: 8)
!330 = distinct !DILexicalBlock(scope: !324, file: !72, line: 328, column: 8)
!331 = !DILocation(line: 328, column: 8, scope: !332)
!332 = distinct !DILexicalBlock(scope: !328, file: !72, line: 328, column: 8)
!333 = !DILocation(line: 328, column: 8, scope: !334)
!334 = distinct !DILexicalBlock(scope: !328, file: !72, line: 328, column: 8)
!335 = !DILocation(line: 328, column: 8, scope: !329)
!336 = distinct !{!336, !337, !337}
!337 = !DILocation(line: 328, column: 8, scope: !330)
!338 = !DILocation(line: 328, column: 6, scope: !121)
!339 = !DILocation(line: 328, column: 2, scope: !121)
!340 = !DILabel(scope: !121, name: "locked", file: !72, line: 330)
!341 = !DILocation(line: 330, column: 1, scope: !121)
!342 = !DILocation(line: 352, column: 7, scope: !343)
!343 = distinct !DILexicalBlock(scope: !121, file: !72, line: 352, column: 6)
!344 = !DILocation(line: 352, column: 11, scope: !343)
!345 = !DILocation(line: 352, column: 30, scope: !343)
!346 = !DILocation(line: 352, column: 27, scope: !343)
!347 = !DILocation(line: 352, column: 6, scope: !121)
!348 = !DILocalVariable(name: "r", scope: !349, file: !72, line: 353, type: !125)
!349 = distinct !DILexicalBlock(scope: !350, file: !72, line: 353, column: 7)
!350 = distinct !DILexicalBlock(scope: !351, file: !72, line: 353, column: 7)
!351 = distinct !DILexicalBlock(scope: !343, file: !72, line: 352, column: 36)
!352 = !DILocation(line: 353, column: 7, scope: !349)
!353 = !DILocation(line: 353, column: 7, scope: !350)
!354 = !DILocation(line: 353, column: 7, scope: !351)
!355 = !DILocation(line: 354, column: 4, scope: !350)
!356 = !DILocation(line: 355, column: 2, scope: !351)
!357 = !DILocation(line: 362, column: 13, scope: !121)
!358 = !DILocation(line: 362, column: 2, scope: !121)
!359 = !DILocation(line: 367, column: 7, scope: !360)
!360 = distinct !DILexicalBlock(scope: !121, file: !72, line: 367, column: 6)
!361 = !DILocation(line: 367, column: 6, scope: !121)
!362 = !DILocalVariable(name: "__PTR", scope: !363, file: !72, line: 368, type: !364)
!363 = distinct !DILexicalBlock(scope: !360, file: !72, line: 368, column: 10)
!364 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !34, size: 64)
!365 = !DILocation(line: 368, column: 10, scope: !363)
!366 = !DILocalVariable(name: "VAL", scope: !363, file: !72, line: 368, type: !34)
!367 = !DILocation(line: 368, column: 10, scope: !368)
!368 = distinct !DILexicalBlock(scope: !369, file: !72, line: 368, column: 10)
!369 = distinct !DILexicalBlock(scope: !370, file: !72, line: 368, column: 10)
!370 = distinct !DILexicalBlock(scope: !363, file: !72, line: 368, column: 10)
!371 = !DILocation(line: 368, column: 10, scope: !372)
!372 = distinct !DILexicalBlock(scope: !368, file: !72, line: 368, column: 10)
!373 = !DILocation(line: 368, column: 10, scope: !374)
!374 = distinct !DILexicalBlock(scope: !368, file: !72, line: 368, column: 10)
!375 = !DILocation(line: 368, column: 10, scope: !369)
!376 = distinct !{!376, !377, !377}
!377 = !DILocation(line: 368, column: 10, scope: !370)
!378 = !DILocation(line: 368, column: 8, scope: !360)
!379 = !DILocation(line: 368, column: 3, scope: !360)
!380 = !DILocation(line: 370, column: 2, scope: !121)
!381 = !DILocation(line: 371, column: 15, scope: !121)
!382 = !DILocation(line: 371, column: 21, scope: !121)
!383 = !DILocation(line: 371, column: 2, scope: !121)
!384 = !DILabel(scope: !121, name: "release", file: !72, line: 373)
!385 = !DILocation(line: 373, column: 1, scope: !121)
!386 = !DILocation(line: 379, column: 2, scope: !121)
!387 = !DILocation(line: 380, column: 1, scope: !121)
!388 = distinct !DISubprogram(name: "virt_spin_lock", scope: !389, file: !389, line: 134, type: !390, scopeLine: 135, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !127)
!389 = !DIFile(filename: "include/asm-generic/qspinlock.h", directory: "/Users/thomashaas/ExternalTools/cna-verification")
!390 = !DISubroutineType(types: !391)
!391 = !{!392, !124}
!392 = !DIBasicType(name: "_Bool", size: 8, encoding: DW_ATE_boolean)
!393 = !DILocalVariable(name: "lock", arg: 1, scope: !388, file: !389, line: 134, type: !124)
!394 = !DILocation(line: 134, column: 62, scope: !388)
!395 = !DILocation(line: 136, column: 2, scope: !388)
!396 = distinct !DISubprogram(name: "queued_fetch_set_pending_acquire", scope: !44, file: !44, line: 185, type: !397, scopeLine: 186, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !127)
!397 = !DISubroutineType(types: !398)
!398 = !{!125, !124}
!399 = !DILocalVariable(name: "lock", arg: 1, scope: !396, file: !44, line: 185, type: !124)
!400 = !DILocation(line: 185, column: 79, scope: !396)
!401 = !DILocation(line: 187, column: 9, scope: !396)
!402 = !DILocation(line: 187, column: 2, scope: !396)
!403 = distinct !DISubprogram(name: "clear_pending", scope: !44, file: !44, line: 132, type: !404, scopeLine: 133, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !127)
!404 = !DISubroutineType(types: !405)
!405 = !{null, !124}
!406 = !DILocalVariable(name: "lock", arg: 1, scope: !403, file: !44, line: 132, type: !124)
!407 = !DILocation(line: 132, column: 61, scope: !403)
!408 = !DILocation(line: 134, column: 2, scope: !403)
!409 = !DILocation(line: 135, column: 1, scope: !403)
!410 = distinct !DISubprogram(name: "clear_pending_set_locked", scope: !44, file: !44, line: 143, type: !404, scopeLine: 144, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !127)
!411 = !DILocalVariable(name: "lock", arg: 1, scope: !410, file: !44, line: 143, type: !124)
!412 = !DILocation(line: 143, column: 72, scope: !410)
!413 = !DILocation(line: 145, column: 2, scope: !410)
!414 = !DILocation(line: 146, column: 1, scope: !410)
!415 = distinct !DISubprogram(name: "get_node", scope: !54, file: !54, line: 87, type: !416, scopeLine: 87, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !127)
!416 = !DISubroutineType(types: !417)
!417 = !{!41, !29}
!418 = !DILocalVariable(name: "cpu", arg: 1, scope: !415, file: !54, line: 87, type: !29)
!419 = !DILocation(line: 87, column: 27, scope: !415)
!420 = !DILocation(line: 87, column: 48, scope: !415)
!421 = !DILocation(line: 87, column: 42, scope: !415)
!422 = !DILocation(line: 87, column: 34, scope: !415)
!423 = distinct !DISubprogram(name: "encode_tail", scope: !44, file: !44, line: 52, type: !424, scopeLine: 53, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !127)
!424 = !DISubroutineType(types: !425)
!425 = !{!125, !29, !29}
!426 = !DILocalVariable(name: "cpu", arg: 1, scope: !423, file: !44, line: 52, type: !29)
!427 = !DILocation(line: 52, column: 42, scope: !423)
!428 = !DILocalVariable(name: "idx", arg: 2, scope: !423, file: !44, line: 52, type: !29)
!429 = !DILocation(line: 52, column: 51, scope: !423)
!430 = !DILocalVariable(name: "tail", scope: !423, file: !44, line: 54, type: !125)
!431 = !DILocation(line: 54, column: 6, scope: !423)
!432 = !DILocation(line: 56, column: 11, scope: !423)
!433 = !DILocation(line: 56, column: 15, scope: !423)
!434 = !DILocation(line: 56, column: 20, scope: !423)
!435 = !DILocation(line: 56, column: 8, scope: !423)
!436 = !DILocation(line: 57, column: 10, scope: !423)
!437 = !DILocation(line: 57, column: 14, scope: !423)
!438 = !DILocation(line: 57, column: 7, scope: !423)
!439 = !DILocation(line: 59, column: 9, scope: !423)
!440 = !DILocation(line: 59, column: 2, scope: !423)
!441 = distinct !DISubprogram(name: "queued_spin_trylock", scope: !389, file: !389, line: 90, type: !442, scopeLine: 91, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !127)
!442 = !DISubroutineType(types: !443)
!443 = !{!29, !124}
!444 = !DILocalVariable(name: "lock", arg: 1, scope: !441, file: !389, line: 90, type: !124)
!445 = !DILocation(line: 90, column: 66, scope: !441)
!446 = !DILocalVariable(name: "val", scope: !441, file: !389, line: 92, type: !29)
!447 = !DILocation(line: 92, column: 6, scope: !441)
!448 = !DILocation(line: 92, column: 12, scope: !441)
!449 = !DILocation(line: 94, column: 6, scope: !450)
!450 = distinct !DILexicalBlock(scope: !441, file: !389, line: 94, column: 6)
!451 = !DILocation(line: 94, column: 6, scope: !441)
!452 = !DILocation(line: 95, column: 3, scope: !450)
!453 = !DILocalVariable(name: "r", scope: !454, file: !389, line: 97, type: !29)
!454 = distinct !DILexicalBlock(scope: !441, file: !389, line: 97, column: 9)
!455 = !DILocation(line: 97, column: 9, scope: !454)
!456 = !DILocation(line: 97, column: 2, scope: !441)
!457 = !DILocation(line: 98, column: 1, scope: !441)
!458 = distinct !DISubprogram(name: "grab_mcs_node", scope: !44, file: !44, line: 72, type: !459, scopeLine: 73, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !127)
!459 = !DISubroutineType(types: !460)
!460 = !{!34, !34, !29}
!461 = !DILocalVariable(name: "base", arg: 1, scope: !458, file: !44, line: 72, type: !34)
!462 = !DILocation(line: 72, column: 57, scope: !458)
!463 = !DILocalVariable(name: "idx", arg: 2, scope: !458, file: !44, line: 72, type: !29)
!464 = !DILocation(line: 72, column: 67, scope: !458)
!465 = !DILocation(line: 74, column: 27, scope: !458)
!466 = !DILocation(line: 74, column: 34, scope: !458)
!467 = !DILocation(line: 74, column: 32, scope: !458)
!468 = !DILocation(line: 74, column: 40, scope: !458)
!469 = !DILocation(line: 74, column: 2, scope: !458)
!470 = distinct !DISubprogram(name: "__pv_init_node", scope: !72, file: !72, line: 87, type: !471, scopeLine: 87, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !127)
!471 = !DISubroutineType(types: !472)
!472 = !{null, !34}
!473 = !DILocalVariable(name: "node", arg: 1, scope: !470, file: !72, line: 87, type: !34)
!474 = !DILocation(line: 87, column: 65, scope: !470)
!475 = !DILocation(line: 87, column: 73, scope: !470)
!476 = distinct !DISubprogram(name: "xchg_tail", scope: !44, file: !44, line: 158, type: !477, scopeLine: 159, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !127)
!477 = !DISubroutineType(types: !478)
!478 = !{!125, !124, !125}
!479 = !DILocalVariable(name: "lock", arg: 1, scope: !476, file: !44, line: 158, type: !124)
!480 = !DILocation(line: 158, column: 56, scope: !476)
!481 = !DILocalVariable(name: "tail", arg: 2, scope: !476, file: !44, line: 158, type: !125)
!482 = !DILocation(line: 158, column: 66, scope: !476)
!483 = !DILocalVariable(name: "old", scope: !476, file: !44, line: 160, type: !125)
!484 = !DILocation(line: 160, column: 6, scope: !476)
!485 = !DILocalVariable(name: "new", scope: !476, file: !44, line: 160, type: !125)
!486 = !DILocation(line: 160, column: 11, scope: !476)
!487 = !DILocation(line: 163, column: 2, scope: !476)
!488 = !DILocation(line: 164, column: 9, scope: !489)
!489 = distinct !DILexicalBlock(scope: !476, file: !44, line: 163, column: 5)
!490 = !DILocation(line: 164, column: 7, scope: !489)
!491 = !DILocation(line: 165, column: 10, scope: !489)
!492 = !DILocation(line: 165, column: 14, scope: !489)
!493 = !DILocation(line: 165, column: 42, scope: !489)
!494 = !DILocation(line: 165, column: 40, scope: !489)
!495 = !DILocation(line: 165, column: 7, scope: !489)
!496 = !DILocation(line: 171, column: 2, scope: !489)
!497 = !DILocalVariable(name: "r", scope: !498, file: !44, line: 171, type: !125)
!498 = distinct !DILexicalBlock(scope: !476, file: !44, line: 171, column: 12)
!499 = !DILocation(line: 171, column: 12, scope: !498)
!500 = !DILocation(line: 171, column: 11, scope: !476)
!501 = distinct !{!501, !487, !502, !245}
!502 = !DILocation(line: 171, column: 61, scope: !476)
!503 = !DILocation(line: 173, column: 9, scope: !476)
!504 = !DILocation(line: 173, column: 2, scope: !476)
!505 = distinct !DISubprogram(name: "decode_tail", scope: !44, file: !44, line: 62, type: !506, scopeLine: 64, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !127)
!506 = !DISubroutineType(types: !507)
!507 = !{!34, !125, !42}
!508 = !DILocalVariable(name: "tail", arg: 1, scope: !505, file: !44, line: 62, type: !125)
!509 = !DILocation(line: 62, column: 59, scope: !505)
!510 = !DILocalVariable(name: "qnodes", arg: 2, scope: !505, file: !44, line: 63, type: !42)
!511 = !DILocation(line: 63, column: 36, scope: !505)
!512 = !DILocalVariable(name: "cpu", scope: !505, file: !44, line: 65, type: !29)
!513 = !DILocation(line: 65, column: 6, scope: !505)
!514 = !DILocation(line: 65, column: 13, scope: !505)
!515 = !DILocation(line: 65, column: 18, scope: !505)
!516 = !DILocation(line: 65, column: 41, scope: !505)
!517 = !DILocalVariable(name: "idx", scope: !505, file: !44, line: 66, type: !29)
!518 = !DILocation(line: 66, column: 6, scope: !505)
!519 = !DILocation(line: 66, column: 13, scope: !505)
!520 = !DILocation(line: 66, column: 18, scope: !505)
!521 = !DILocation(line: 66, column: 39, scope: !505)
!522 = !DILocation(line: 68, column: 9, scope: !505)
!523 = !DILocation(line: 68, column: 2, scope: !505)
!524 = distinct !DISubprogram(name: "__pv_wait_node", scope: !72, file: !72, line: 88, type: !525, scopeLine: 89, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !127)
!525 = !DISubroutineType(types: !526)
!526 = !{null, !34, !34}
!527 = !DILocalVariable(name: "node", arg: 1, scope: !524, file: !72, line: 88, type: !34)
!528 = !DILocation(line: 88, column: 65, scope: !524)
!529 = !DILocalVariable(name: "prev", arg: 2, scope: !524, file: !72, line: 89, type: !34)
!530 = !DILocation(line: 89, column: 30, scope: !524)
!531 = !DILocation(line: 89, column: 38, scope: !524)
!532 = distinct !DISubprogram(name: "__pv_wait_head_or_lock", scope: !72, file: !72, line: 92, type: !533, scopeLine: 94, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !127)
!533 = !DISubroutineType(types: !534)
!534 = !{!125, !124, !34}
!535 = !DILocalVariable(name: "lock", arg: 1, scope: !532, file: !72, line: 92, type: !124)
!536 = !DILocation(line: 92, column: 70, scope: !532)
!537 = !DILocalVariable(name: "node", arg: 2, scope: !532, file: !72, line: 93, type: !34)
!538 = !DILocation(line: 93, column: 31, scope: !532)
!539 = !DILocation(line: 94, column: 12, scope: !532)
!540 = distinct !DISubprogram(name: "set_locked", scope: !44, file: !44, line: 197, type: !404, scopeLine: 198, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !127)
!541 = !DILocalVariable(name: "lock", arg: 1, scope: !540, file: !44, line: 197, type: !124)
!542 = !DILocation(line: 197, column: 58, scope: !540)
!543 = !DILocation(line: 199, column: 2, scope: !540)
!544 = !DILocation(line: 201, column: 1, scope: !540)
!545 = distinct !DISubprogram(name: "__pv_kick_node", scope: !72, file: !72, line: 90, type: !546, scopeLine: 91, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !127)
!546 = !DISubroutineType(types: !547)
!547 = !{null, !124, !34}
!548 = !DILocalVariable(name: "lock", arg: 1, scope: !545, file: !72, line: 90, type: !124)
!549 = !DILocation(line: 90, column: 62, scope: !545)
!550 = !DILocalVariable(name: "node", arg: 2, scope: !545, file: !72, line: 91, type: !34)
!551 = !DILocation(line: 91, column: 30, scope: !545)
!552 = !DILocation(line: 91, column: 38, scope: !545)
!553 = distinct !DISubprogram(name: "main", scope: !54, file: !54, line: 105, type: !554, scopeLine: 106, spFlags: DISPFlagDefinition, unit: !2, retainedNodes: !127)
!554 = !DISubroutineType(types: !555)
!555 = !{!29}
!556 = !DILocalVariable(name: "t", scope: !553, file: !54, line: 107, type: !557)
!557 = !DICompositeType(tag: DW_TAG_array_type, baseType: !558, size: 256, elements: !580)
!558 = !DIDerivedType(tag: DW_TAG_typedef, name: "pthread_t", file: !559, line: 31, baseType: !560)
!559 = !DIFile(filename: "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/sys/_pthread/_pthread_t.h", directory: "")
!560 = !DIDerivedType(tag: DW_TAG_typedef, name: "__darwin_pthread_t", file: !561, line: 118, baseType: !562)
!561 = !DIFile(filename: "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/sys/_pthread/_pthread_types.h", directory: "")
!562 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !563, size: 64)
!563 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_opaque_pthread_t", file: !561, line: 103, size: 65536, elements: !564)
!564 = !{!565, !566, !576}
!565 = !DIDerivedType(tag: DW_TAG_member, name: "__sig", scope: !563, file: !561, line: 104, baseType: !33, size: 64)
!566 = !DIDerivedType(tag: DW_TAG_member, name: "__cleanup_stack", scope: !563, file: !561, line: 105, baseType: !567, size: 64, offset: 64)
!567 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !568, size: 64)
!568 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "__darwin_pthread_handler_rec", file: !561, line: 57, size: 192, elements: !569)
!569 = !{!570, !574, !575}
!570 = !DIDerivedType(tag: DW_TAG_member, name: "__routine", scope: !568, file: !561, line: 58, baseType: !571, size: 64)
!571 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !572, size: 64)
!572 = !DISubroutineType(types: !573)
!573 = !{null, !41}
!574 = !DIDerivedType(tag: DW_TAG_member, name: "__arg", scope: !568, file: !561, line: 59, baseType: !41, size: 64, offset: 64)
!575 = !DIDerivedType(tag: DW_TAG_member, name: "__next", scope: !568, file: !561, line: 60, baseType: !567, size: 64, offset: 128)
!576 = !DIDerivedType(tag: DW_TAG_member, name: "__opaque", scope: !563, file: !561, line: 106, baseType: !577, size: 65408, offset: 128)
!577 = !DICompositeType(tag: DW_TAG_array_type, baseType: !57, size: 65408, elements: !578)
!578 = !{!579}
!579 = !DISubrange(count: 8176)
!580 = !{!76}
!581 = !DILocation(line: 107, column: 15, scope: !553)
!582 = !DILocalVariable(name: "i", scope: !583, file: !54, line: 111, type: !29)
!583 = distinct !DILexicalBlock(scope: !553, file: !54, line: 111, column: 5)
!584 = !DILocation(line: 111, column: 14, scope: !583)
!585 = !DILocation(line: 111, column: 10, scope: !583)
!586 = !DILocation(line: 111, column: 21, scope: !587)
!587 = distinct !DILexicalBlock(scope: !583, file: !54, line: 111, column: 5)
!588 = !DILocation(line: 111, column: 23, scope: !587)
!589 = !DILocation(line: 111, column: 5, scope: !583)
!590 = !DILocation(line: 112, column: 27, scope: !587)
!591 = !DILocation(line: 112, column: 25, scope: !587)
!592 = !DILocation(line: 112, column: 47, scope: !587)
!593 = !DILocation(line: 112, column: 39, scope: !587)
!594 = !DILocation(line: 112, column: 9, scope: !587)
!595 = !DILocation(line: 111, column: 36, scope: !587)
!596 = !DILocation(line: 111, column: 5, scope: !587)
!597 = distinct !{!597, !589, !598, !245}
!598 = !DILocation(line: 112, column: 48, scope: !583)
!599 = !DILocalVariable(name: "i", scope: !600, file: !54, line: 116, type: !29)
!600 = distinct !DILexicalBlock(scope: !553, file: !54, line: 116, column: 5)
!601 = !DILocation(line: 116, column: 14, scope: !600)
!602 = !DILocation(line: 116, column: 10, scope: !600)
!603 = !DILocation(line: 116, column: 21, scope: !604)
!604 = distinct !DILexicalBlock(scope: !600, file: !54, line: 116, column: 5)
!605 = !DILocation(line: 116, column: 23, scope: !604)
!606 = !DILocation(line: 116, column: 5, scope: !600)
!607 = !DILocation(line: 117, column: 24, scope: !604)
!608 = !DILocation(line: 117, column: 22, scope: !604)
!609 = !DILocation(line: 117, column: 9, scope: !604)
!610 = !DILocation(line: 116, column: 36, scope: !604)
!611 = !DILocation(line: 116, column: 5, scope: !604)
!612 = distinct !{!612, !606, !613, !245}
!613 = !DILocation(line: 117, column: 29, scope: !600)
!614 = !DILocation(line: 119, column: 5, scope: !553)
!615 = !DILocation(line: 121, column: 2, scope: !553)
!616 = distinct !DISubprogram(name: "run", scope: !54, file: !54, line: 93, type: !617, scopeLine: 94, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !127)
!617 = !DISubroutineType(types: !618)
!618 = !{!41, !41}
!619 = !DILocalVariable(name: "arg", arg: 1, scope: !616, file: !54, line: 93, type: !41)
!620 = !DILocation(line: 93, column: 24, scope: !616)
!621 = !DILocation(line: 95, column: 18, scope: !616)
!622 = !DILocation(line: 95, column: 8, scope: !616)
!623 = !DILocation(line: 95, column: 2, scope: !616)
!624 = !DILocation(line: 95, column: 6, scope: !616)
!625 = !DILocation(line: 97, column: 2, scope: !616)
!626 = !DILocation(line: 98, column: 6, scope: !616)
!627 = !DILocation(line: 98, column: 8, scope: !616)
!628 = !DILocation(line: 98, column: 4, scope: !616)
!629 = !DILocation(line: 99, column: 6, scope: !616)
!630 = !DILocation(line: 99, column: 8, scope: !616)
!631 = !DILocation(line: 99, column: 4, scope: !616)
!632 = !DILocation(line: 100, column: 2, scope: !616)
!633 = !DILocation(line: 102, column: 2, scope: !616)
!634 = distinct !DISubprogram(name: "queued_spin_lock", scope: !389, file: !389, line: 107, type: !404, scopeLine: 108, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !127)
!635 = !DILocalVariable(name: "lock", arg: 1, scope: !634, file: !389, line: 107, type: !124)
!636 = !DILocation(line: 107, column: 64, scope: !634)
!637 = !DILocalVariable(name: "val", scope: !634, file: !389, line: 109, type: !29)
!638 = !DILocation(line: 109, column: 6, scope: !634)
!639 = !DILocalVariable(name: "r", scope: !640, file: !389, line: 111, type: !29)
!640 = distinct !DILexicalBlock(scope: !641, file: !389, line: 111, column: 6)
!641 = distinct !DILexicalBlock(scope: !634, file: !389, line: 111, column: 6)
!642 = !DILocation(line: 111, column: 6, scope: !640)
!643 = !DILocation(line: 111, column: 6, scope: !641)
!644 = !DILocation(line: 111, column: 6, scope: !634)
!645 = !DILocation(line: 112, column: 3, scope: !641)
!646 = !DILocation(line: 114, column: 28, scope: !634)
!647 = !DILocation(line: 114, column: 34, scope: !634)
!648 = !DILocation(line: 114, column: 2, scope: !634)
!649 = !DILocation(line: 115, column: 1, scope: !634)
!650 = distinct !DISubprogram(name: "queued_spin_unlock", scope: !389, file: !389, line: 123, type: !404, scopeLine: 124, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition, unit: !2, retainedNodes: !127)
!651 = !DILocalVariable(name: "lock", arg: 1, scope: !650, file: !389, line: 123, type: !124)
!652 = !DILocation(line: 123, column: 66, scope: !650)
!653 = !DILocation(line: 128, column: 2, scope: !650)
!654 = !DILocation(line: 130, column: 1, scope: !650)
