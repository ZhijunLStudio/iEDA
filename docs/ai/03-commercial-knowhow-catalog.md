<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 03 · 商业 EDA Know-how 推演目录 · v1.0

> 日期：2026-07-20  
> 目的：把 **Innovus / ICC2 / PrimeTime / StarRC / Calibre / PTPX / Voltus / Genus / DC** 等商业工具里「不写进用户手册、但决定 QoR 上限」的工程手法，整理成可落地的假说清单，供各工具方案引用。  
> 纪律：**推演 ≠ 逆向工程**；下列条目是行业公开论文、contest、工具行为观察与工程常识的综合假说；每条必须绑定「能杀死它的对照实验」；未验证前不得写成「商业已证实如此」。  
> 用法：各 `2x-*.md` 的「§ 商业 Know-how」引用本目录编号 `KH-<域>-nn`。

---

## 0. 横切 Know-how（全流程）

| ID | Know-how | 直觉 | iEDA 落点 | 杀死实验 |
|---|---|---|---|---|
| KH-X-01 | **同一真值源闭环** | 优化用的 slack/RC/功耗必须与签核口径可对齐，否则越修越偏 | iSTA G7、iRCX G8 先于 G17 | 用 PT 读双方 DEF 比「iSTA 自评」 |
| KH-X-02 | **努力档位可复现** | 商业 `effort` 本质是参数包+迭代预算，不是魔法 | parity_protocol 冻结 effort | 同设计两档 effort QoR 单调 |
| KH-X-03 | **增量 session** | 不落盘重读 → 状态一致、ECO 快 | G16 单 session | 断点续跑产物一致 |
| KH-X-04 | **响亮失败** | 假成功比慢更致命 | G14 | 空操作必非 rc 成功 |
| KH-X-05 | **多目标分层** | 先合法/DRC，再 WNS，再功耗/面积，最后墙钟 | 门禁分层 G2→G5→G6→G17→G21 | 颠倒顺序必回归失败 |
| KH-X-06 | **热点导向迭代** | 不全图盲迭代；对 worst region/path/net 加码 | iPL/iRT/iTO/iCTS | 热点外指标几乎不变 |
| KH-X-07 | **物理感知贯穿** | 综合→CTS→opt 都吃 placement/route 估计 | iNO/iTO/iCTS | 关物理估计 QoR 变差 |
| KH-X-08 | **不确定度带** | 两次复跑波动计入对比 | parity ε | 波动 >δ 则不宣称打平 |

---

## 1. 数据库 / 平台 / 接口

| ID | Know-how | 商业侧表现 | iEDA |
|---|---|---|---|
| KH-DB-01 | 二进制流片格式唯一真源 | GDSII/OASIS 二进制；文本仅调试 | 10-iDB：禁 ASCII 冒充 GDS |
| KH-DB-02 | 属性往返不丢 | DEF STATUS/PROPERTY/OWNERSHIP | LEF/DEF/SPEF/SDC round-trip |
| KH-DB-03 | 容量分层驻留 | 大设计不一次全展开几何 | 容量爬坡 G13 |
| KH-IF-01 | 命令=事务 | 失败回滚或明确脏状态 | 41-interface |
| KH-PLAT-01 | 引擎顺序契约 | eval 不得早于寄生就绪 | 40-platform |
| KH-PLAT-02 | 度量外生 | budget 不来自自身输出 | G15 |

---

## 2. 布图 / 布局（floorplan & place）

| ID | Know-how | 算法直觉 | iEDA 落点 |
|---|---|---|---|
| KH-FP-01 | **通道与 pin-access 预留** | 宏间距由飞行线+层资源反推，不是均匀塞 | 20-iFP 约束模型 + 22 宏 cost |
| KH-FP-02 | **util 预算保守** | 商业默认 util 常留拥塞余量（~0.55–0.70 视工艺） | auto-die util 可配 |
| KH-FP-03 | **IO–宏–标准单元分层决策** | IO 先/宏次/std 后，或迭代回灌 | iFP→iPL 交接 |
| KH-PL-01 | **解析初值 + 非线性精化** | QP/B2B 初值 → Nesterov/eDensity | 22 QP |
| KH-PL-02 | **密度屏/FFT 静电类** | 全局密度平滑避免局部爆炸 | Nesterov 保持 |
| KH-PL-03 | **WA/LSE 线长可微** | 平滑 HPWL 以求导 | 已有 WA |
| KH-PL-04 | **时序净权重+路径共享** | 关键网加权，避免重复计路径 | TimingAnnotation |
| KH-PL-05 | **拥塞→局部 inflat** | GR 估计回灌 density | FR-PL-09 |
| KH-PL-06 | **合法化失败即停** | Abacus 丢单元=流程失败 | G14/G2 |
| KH-PL-07 | **渐进/增量 GP** | ECO 只动局部 | PostGP/incr LG |
| KH-PL-08 | **宏=离散+连续混合** | 力导向连续 + SA/MIP 离散 | MacroPlacer |

---

## 3. 时钟树（CTS / ccopt）

| ID | Know-how | 算法直觉 | iEDA |
|---|---|---|---|
| KH-CTS-01 | **局部 skew 重于全局** | 同路径相关寄存器对的 skew | bound-skew / 报告分组 |
| KH-CTS-02 | **useful skew = 时序预算搬家** | 正/负 skew 吃 setup/hold 裕量 | FR-CTS-04 |
| KH-CTS-03 | **延迟/功耗/skew 三目标** | 非单一 min-skew | G19 三指标 |
| KH-CTS-04 | **时钟 NDR+屏蔽** | 降 SI、控 RC | iRT NDR Phase C |
| KH-CTS-05 | **buffer 后必 legalize** | 插入单元重叠毁 route | incr LG |
| KH-CTS-06 | **mesh / tree / hybrid** | 顶层 mesh 降 skew，底层 tree | 现有 H 树+可扩 |
| KH-CTS-07 | **时钟门控感知** | enable 路径不破坏 | SDC clock gate |

---

## 4. 布线（NanoRoute / ICC2 route）

| ID | Know-how | 算法直觉 | iEDA |
|---|---|---|---|
| KH-RT-01 | **历史代价 / PathFinder** | 反复占道抬价逼疏散 | DR 代价调度 |
| KH-RT-02 | **热点撕布重布** | plateau 后换策略非原样重复 | FR-RT-01 |
| KH-RT-03 | **自适应 box** | 密区大窗口、稀区小窗口 | FR-RT-02 |
| KH-RT-04 | **关键网优先** | slack 排序 / 层偏置 | FR-RT-04 |
| KH-RT-05 | **SI 间距膨胀** | 耦合大 → 间距/屏蔽 | Phase C |
| KH-RT-06 | **天线/via 柱规则从 tech 来** | 禁写死层号 | 红线 |
| KH-RT-07 | **ECO 局部拆线** | 其余网冻结 | routeECO |
| KH-RT-08 | **GR 指导 DR** | 拥塞图指导层分配 | ER/LA 管线 |

---

## 5. 时序分析与优化（PT / Tempus / route_opt）

| ID | Know-how | 算法直觉 | iEDA |
|---|---|---|---|
| KH-STA-01 | **GBA 筛查 + PBA 终审** | 去重收敛悲观 | 27 PBA |
| KH-STA-02 | **CPPR / CRPR** | 公共时钟路径去悲观 | StaCppr |
| KH-STA-03 | **AOCV/POCV 深度 derate** | 路径越长越不相关 | readAocv |
| KH-STA-04 | **SI delta 进 slack** | 无耦合则无真 SI-opt | 27+28 |
| KH-STA-05 | **增量锥失效** | ECO/place 只重算扇出锥 | §6.E |
| KH-STA-06 | **path group 分治** | reg2reg / in2reg / reg2out | 报告分组 |
| KH-TO-01 | **灵敏度/路径收益否决** | 局部优可能全局劣 | 25 否决环 |
| KH-TO-02 | **VT-swap 优先于大改布局** | 漏电-时序便宜手柄 | FR-TO-03 |
| KH-TO-03 | **DRV→setup→hold→复扫** | 固定内建序 | AutoRun |
| KH-TO-04 | **物理感知缓冲树** | van Ginneken + 合法化 | buffers+LG |
| KH-TO-05 | **sizing 与负载电容闭环** | 换大门拖垮前级 | 否决环 |

---

## 6. 提取 / 功耗 / IR / DRC / LVS

| ID | Know-how | 算法直觉 | iEDA |
|---|---|---|---|
| KH-RCX-01 | **pattern + field-solver 标定** | 规则快、场解准，用后者校准前者 | 28 G8 |
| KH-RCX-02 | **耦合必须可被 STA 消费** | SPEF CC 挂点真实 | SpefDumper |
| KH-RCX-03 | **增量提取** | dirty net 邻域 | FR-RCX-04 |
| KH-PA-01 | **无活动源则拒报** | 默认 toggle 是假数 | G9 |
| KH-PA-02 | **时钟/leakage/dynamic 分解** | 优化手柄不同 | iPA 报告 |
| KH-IR-01 | **真 PG + 残差收敛** | 非标量电阻网 | iIR residual |
| KH-IR-02 | **动态 IR 看峰值事件** | VCD 窗口 | Phase C |
| KH-DRC-01 | **覆盖表透明** | SKIP≠PASS | G11 |
| KH-DRC-02 | **in-design vs signoff 分层** | 速度/完备折中 | iDRC+Calibre |
| KH-LVS-01 | **参考网表独立** | 防恒等式 | G12 |
| KH-LVS-02 | **注入差异必报** | 最便宜保险 | G12 |

---

## 7. 综合 / ECO / 评测

| ID | Know-how | iEDA |
|---|---|---|
| KH-SYN-01 | 物理感知综合（place-aware） | 21/33 |
| KH-SYN-02 | 多 VT / 多 corner 库映射 Pareto | 33 G18 |
| KH-ECO-01 | 功能 ECO=等价变换+金属可修 | 32 |
| KH-ECO-02 | 时序 ECO= iTO+iRT incr 闭环 | 32 |
| KH-EV-01 | 并排金参考 + 分项墙钟 | 12/42 |
| KH-EV-02 | 逐指标独立转绿 | G17 |

---

## 8. 与阶段的绑定（摘）

| 阶段 | 优先启用的 Know-how |
|---|---|
| Phase 0 | KH-X-01/04/08，KH-EV-*，各工具「先量」 |
| Phase A | KH-X-04，KH-DRC-01，KH-LVS-*，KH-DB-01 |
| Phase B0 | KH-STA-*，KH-RCX-01/02 |
| Phase B1 | KH-PL-*，KH-FP-* |
| Phase B2 | KH-RT-01..04，KH-CTS-01/05 |
| Phase B3 | KH-TO-*，KH-CTS-02 |
| Phase C | KH-RT-05/07，KH-ECO-*，KH-SYN-* |

### 8.1 统一演进模板（各工具方案已对齐）

每个工具文档的演进节采用同一骨架：

```text
M0 先量/审计（对照实验） → 看见与商业的数字差
M1 可信度（响亮失败、门禁、契约）
M2 核心算法补齐（本工具主杠杆）
M3 与商业金参考打平爬坡（G7/G8/G11/G17…）
M4 性能/增量/纵深（G21、ECO、规模）
```

对照商业时固定三件套：**看板指标表 + 对照实验 ID + M0–M4 退出门禁**。细节见各 `1x/2x/3x/4x-*.md`。

---

## 附录 · 引用约定

各工具文档新增章节标题统一为：

```text
## N. 商业 Know-how 推演（引用 03 目录）
```

表格列：`KH-ID | 推演要点 | 本工具落地 | 对照实验 | 优先级`。
