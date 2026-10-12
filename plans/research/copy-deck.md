# flow — Website Copy Deck & Vietnamese Localization Research
**Document path:** `plans/research/copy-deck.md`  
**Date:** 2026-10-12  
**Role:** Bilingual Copywriter (EN + VI)  
**Status:** Approved for Implementation on `feat/copy-refresh`  

---

## 1. Executive Summary & Problem Analysis

### 1.1 The Operator's Complaint
The operator flagged that the Vietnamese copy on the website reads stiff, translated-English-sounding ("dịch máy", translation-ese), and semantically awkward when sentences are joined together ("cứng nhắc khó hiểu không hợp nghĩa khi gắn kết với nhau").

**Flagged Example:**
> *"Cổng chỉ mở khi cả hai bên cùng đồng ý."*

### 1.2 Root Cause Diagnosis
A granular forensic linguistic audit of the initial Vietnamese copy revealed five systemic failure modes:

1. **Over-translation of Established Developer Loanwords ("Dịch gượng ép"):**
   - `"gate"` was mechanically translated to `"cổng"` across 100% of the site. In Vietnamese tech culture, "cổng" primarily denotes a physical gate (cổng nhà, cổng trường), a network port (cổng 8080), or an API/payment gateway (cổng thanh toán). Quality gates and pipeline checkpoints in software engineering are universally referred to by Vietnamese developers as **"gate"** (e.g., "pass gate", "chặn ở gate", "quality gate"). Translating it to "cổng" made the technical harness sound like an ancient fable or medieval fortress.
   - `"deliverable slices"` became `"lát cắt bàn giao"` (evoking slices of sausage or bread rather than vertical feature slices).
   - `"reversibility mapped"` became `"đã lập bản đồ hoàn tác"` (a word-for-word calque of "map" into "bản đồ").
   - `"degraded mode / paths"` became `"phương án suy thoái"` (in Vietnamese, "suy thoái" strictly denotes economic recession or moral degradation, never graceful software degradation).
   - `"negative test cases"` became `"ca kiểm thử âm"` (evoking medical diagnostics like negative COVID results rather than failure test cases).

2. **Legalistic / Interpersonal Calques ("Văn bản dân sự thay vì kỹ thuật"):**
   - *"Cổng chỉ mở khi cả hai bên cùng đồng ý"* sounds like two parties (Bên A and Bên B) negotiating a divorce settlement or commercial dispute. In flow, the two checking entities are the mechanical runner (`flow.sh`) and the semantic skill rules (`SKILL.md`). In developer parlance, systems don't "đồng ý" (consent/agree); they **"cùng duyệt"**, **"cùng pass"**, or **"cùng xác nhận"**.

3. **Passive and Wordy Syntax ("Hán-Việt hành chính & câu bị động"):**
   - Sentences were bloated with bureaucratic filler: `"được thực hiện"`, `"phương án"`, `"biên giới phi mục tiêu"` (border and non-targets), `"chưa cùng đồng ý"`.

4. **Direct Violation of the Brand Voice Laws:**
   - `brand/brand-brief.md` explicit rule (line 71):
     > *"Thuật ngữ kỹ thuật giữ nguyên khi cộng đồng đã dùng tiếng Anh: gate, stage, receipt, runtime, card. Phần diễn giải dùng tiếng Việt tự nhiên."*
   - The original Vietnamese copy ignored this invariant, turning every technical entity into awkward Vietnamese neologisms.

---

## 2. Vietnamese Tech Copywriting Principles (Research & Theoretical Foundation)

### 2.1 The Target Persona & The Coffee Test
The audience consists of Vietnamese developers and team leads using Claude Code, OpenAI Codex CLI, Cursor, and Aider on production codebases. They are terminal residents who code-switch effortlessly between English technical terms and natural Vietnamese prose.

**The Test of Truth ("The Coffee Test"):**
> *If a senior Vietnamese software engineer cannot say the line out loud to a peer over coffee without cringing or pausing to explain, the line fails.*

### 2.2 Five Core Principles for Flow Copy

1. **Keep Technical Terms in English When Devs Use Them (Giữ thuật ngữ dev):**
   - Keep: `gate`, `stage`, `runner`, `skill`, `runtime`, `card`, `scope`, `PRD`, `ADR`, `contract`, `build`, `deploy`, `URL`, `commit`, `rollback`, `degrade`, `telemetry`, `exit code`.
   - Explain naturally: Use natural Vietnamese around the anchor terms.
2. **Short, Declarative, Active Sentences (≤ 20 words, Chủ động, Động từ đặt sớm):**
   - Cut passive auxiliaries (`được`, `bị` when neutral). Lead with verbs: "Khóa cứng", "Gói gọn", "Chặn đứng", "Loại bỏ".
3. **Concrete Numbers Over Vague Adjectives (Số > Tính từ):**
   - "6 gate", "3 nguồn tài liệu gốc", "4 điều kiện bất biến".
4. **Purge Bureaucratic Sino-Vietnamese (Bỏ Hán-Việt hành chính thừa):**
   - Replace `"phương án suy thoái"` with `"luồng xử lý degrade"`.
   - Replace `"ca kiểm thử âm"` with `"kịch bản kiểm thử lỗi"`.
   - Replace `"phi mục tiêu"` with `"non-goals"`.
   - Replace `"lát cắt bàn giao"` with `"phần việc bàn giao"`.
5. **Brand Tone: Blunt, Disciplined, Friction-Honest (Đanh thép, kỷ luật, trung thực):**
   - Flow does not sell magic or "10x". It sells provable discipline and honored gate halts. Halting at a gate is a success of the harness, not a failure of the tool.

---

## 3. The Critical Decision: "Gate" vs "Cổng"

### 3.1 Analysis
| Metric | "Cổng" | "Gate" |
|---|---|---|
| **Developer familiarity** | Low/Misleading (confused with Network Port 8080 or Payment Gateway) | Universal (Quality Gate, Release Gate, Gated Check-in) |
| **Brand brief adherence** | Violates `brand-brief.md` line 71 | 100% compliant with `brand-brief.md` line 71 |
| **Phonetic punch** | 1 syllable, but softer tone | 1 syllable, sharp plosive ending (`/t/`), commanding and terminal-native |
| **Natural phrasing** | "qua cổng", "chặn ở cổng" (sounds like school security gate) | "qua gate", "chặn tại gate", "pass gate" (exact dev vernacular) |

### 3.2 Definitive Recommendation
**Recommendation: Use "gate" as the primary noun across all website copy.**
- In explanatory prose or hero positioning, "harness kiểm soát bằng gate" or "khung kiểm soát có gate" clarifies the role of flow without forcing a clumsy translation.
- In all headlines, pipeline headers, badges, artifact logs, receipts, and verdicts, use **"gate"**.

---

## 4. Headline Proposals & Recommendation

### English Headline
| # | Option | Tone & Rationale | Status |
|---|---|---|---|
| 1 | **Hollow work does not advance.** | Stoic, blunt, philosophical yet concrete. Captures the essence of hollow AI agent outputs. | **RECOMMENDED** |
| 2 | **No proof, no progress.** | Rhythmic, high-velocity, directly echoes "proof over vibes". | Alternative |
| 3 | **Vibes don't clear the gate.** | Punchy, modern dev-slang contrast, slightly more informal. | Alternative |

### Vietnamese Headline
| # | Option | Tone & Rationale | Status |
|---|---|---|---|
| 1 | **Tiến độ ảo không qua được gate.** | **Ultra-sharp.** "Tiến độ ảo" is the exact Vietnamese term for the illusion of progress created by AI agents (hallucinated tests, fake passes, hollow stubs). Devs instantly nod in recognition. | **RECOMMENDED** |
| 2 | **Làm đối phó không thể qua gate.** | Strong and blunt. "Làm đối phó" captures mock/stub generation to bypass checks. | Alternative |
| 3 | **Không có bằng chứng, không qua gate.** | Direct parallel to "Bằng chứng hơn cảm hứng". Clean and rhythmic. | Alternative |

---

## 5. Verdict Line Proposals & Recommendation

**Original English:** `The gate opens only when both agree.`  
**Original Vietnamese:** `Cổng chỉ mở khi cả hai bên cùng đồng ý.` *(Flagged as awkward)*

### Vietnamese Alternatives Ranked by Naturalness:
| Rank | Option | Read-Aloud & Coffee Test Evaluation | Status |
|---|---|---|---|
| **#1** | **Gate chỉ mở khi cả hai cùng duyệt.** | **Perfect naturalness.** "Duyệt" is the authoritative engineering term for code/artifact review and gate approval. 8 words, rhythmically balanced, instantly clear without explanation. | **RECOMMENDED** |
| **#2** | **Cả hai cùng pass, gate mới mở.** | **Ultra-conversational dev speak.** Condition first, result second. Uses "pass", which is standard in Vietnamese dev teams. Highly natural, slightly more colloquial. | Alternative |
| **#3** | **Gate chỉ qua khi cả hai cùng khớp.** | **Mechanical/metaphorical focus.** Connects with "hai chìa khóa, một gate" (dual-key alignment). Very poetic and precise, slightly less direct than #1. | Alternative |

---

## 6. Master Copy Deck: Granular Before & After Inventory

This table inventories EVERY string across `website/src/pages/index.astro`, `website/src/pages/vi/index.astro`, `website/src/components/InstallLockup.astro`, and `website/src/components/Colophon.astro`.

### Section A: Meta & Document Header
| Key / Location | Current EN | Rewritten EN | Current VI | Rewritten VI | Diagnostic Rationale (Why rewrite?) |
|---|---|---|---|---|---|
| Page Title (`<title>`) | `flow — hollow work does not advance` | `flow — hollow work does not advance` | `flow: cổng chặn việc rỗng` | `flow — tiến độ ảo không qua được gate` | "việc rỗng" is an unnatural calque. "Tiến độ ảo" captures AI agent hollow completes. |
| Meta Description | `A gated harness around the coding agent you already use. npx @manhquy/flow-skill@next. Killing a weak idea at a gate is valid. Not an agent.` | `A gated harness around the coding agent you already use. npx @manhquy/flow-skill@latest. Killing a weak idea at a gate is valid. Not an agent.` | `Agent vẫn viết code, còn cổng mở hay đóng thì flow quyết. Phải cả flow.sh lẫn skill thì cổng mới mở. Bị chặn ở cổng thì dừng luôn, chứ không phải fail. npx @manhquy/flow-skill@next` | `Harness kiểm soát bằng gate cho coding agent bạn đang dùng. flow giữ gate và biên nhận, không can thiệp runtime. Dừng ở gate là kết quả hợp lệ. npx @manhquy/flow-skill@latest` | Replaced fragmented, run-on sentences with crisp, authoritative positioning. Updated `@next` to `@latest`. |
| Hero Section `aria-label` | `Install and outcomes` | `Install and outcomes` | `Cài rồi cổng` | `Cài đặt và kết quả kiểm chứng` | "Cài rồi cổng" is nonsensical translation-ese. |

### Section B: Hero Section
| Key / Location | Current EN | Rewritten EN | Current VI | Rewritten VI | Diagnostic Rationale (Why rewrite?) |
|---|---|---|---|---|---|
| Kicker | `PROOF OVER VIBES.` | `PROOF OVER VIBES.` | `BẰNG CHỨNG HƠN CẢM HỨNG.` | `BẰNG CHỨNG HƠN CẢM HỨNG.` | Brand tagline #1 invariant; keep. |
| Display mark | `flow` | `flow` | `flow` | `flow` | Wordmark invariant. |
| Headline (`<h1>`) | `Hollow work does not advance.` | `Hollow work does not advance.` | `Việc rỗng thì không qua cổng.` | `Tiến độ ảo không qua được gate.` | Replaces literal "việc rỗng... cổng" with sharp dev idiom "tiến độ ảo... gate". |
| Lede Paragraph | `A gated harness around the coding agent you already use. Flow owns the gates and the receipts, never the runtime. Killing a weak idea at a gate is a valid outcome.` | `A gated harness around the coding agent you already use. Flow owns the gates and the receipts, never the runtime. Killing a weak idea at a gate is a valid outcome.` | `flow là khung kiểm soát quanh coding agent bạn đang dùng. flow giữ cổng và bằng chứng, chứ không chạy thay agent. Bị chặn ở cổng thì dừng luôn, chứ không phải fail.` | `flow là harness kiểm soát bằng gate cho coding agent bạn đang dùng. flow giữ gate và biên nhận, không can thiệp runtime. Dừng lại ở gate là kết quả hợp lệ, được ghi nhận.` | Replaced clunky "khung kiểm soát... giữ cổng và bằng chứng" with clear harness/gate/biên nhận/runtime vocabulary. |
| Verdict Line | `The gate opens only when both agree.` | `The gate opens only when both agree.` | `Cổng chỉ mở khi cả hai bên cùng đồng ý.` | `Gate chỉ mở khi cả hai cùng duyệt.` | **Flagged example fixed.** Replaces legalistic "cả hai bên cùng đồng ý" with engineering-accurate "cả hai cùng duyệt". |
| Install Widget Copy Label | `Copy` | `Copy` | `Copy` | `Copy` | Clean dev standard. |
| Install Widget Copied Label | `Copied` | `Copied` | `Đã copy` | `Đã copy` | Natural. |
| Install Widget Select Fallback | `Selected — press Ctrl+C` | `Selected — press Ctrl+C` | `Đã bôi đen — bấm Ctrl+C` | `Đã chọn — nhấn Ctrl+C` | "Bôi đen" sounds archaic; "Đã chọn — nhấn Ctrl+C" is professional. |
| Install Widget Secondary Link | `Install and first run` | `Install and first run` | `Cài rồi chạy thử` | `Cài đặt và lần chạy đầu` | Aligns with README_VN and docs tutorial title. |
| Marquee Label | `WORKS WITH YOUR CODING AGENTS` | `WORKS WITH YOUR CODING AGENTS` | `TƯƠNG THÍCH VỚI CÁC CODING AGENT` | `HOẠT ĐỘNG CÙNG CÁC CODING AGENT BẠN DÙNG` | More active and relational than generic "tương thích". |
| Marquee Region `aria-label` | `Coding agent badges` | `Coding agent badges` | `Các coding agent được hỗ trợ` | `Danh sách coding agent tương thích` | Clear and standard. |

### Section C: Numbered Gates Overview (Run Section)
| Key / Location | Current EN | Rewritten EN | Current VI | Rewritten VI | Diagnostic Rationale (Why rewrite?) |
|---|---|---|---|---|---|
| Section Title (`<h2>`) | `Six gates before you build` | `Six gates before you build` | `Sáu cổng trước khi bạn build` | `6 gate kiểm soát trước khi build` | Digits over words ("6" > "Sáu"). "Gate kiểm soát" clarifies technical role. |
| Section Lede | `Each stage writes a real file in your repo. /flow next will not unlock the next one until the runner and the skill both agree. Those files exist after you walk the gates, not after install.` | `Each stage writes a real file in your repo. /flow next will not unlock the next one until the runner and the skill both agree. Those files exist after you walk the gates, not after install.` | `Mỗi cổng viết ra một file thật trong repo. /flow next không cho qua cổng tiếp theo nếu cả flow.sh lẫn skill chưa cùng đồng ý. Các file này xuất hiện khi bạn đi qua cổng, không phải có sẵn sau khi cài.` | `Mỗi stage ghi một file thật vào repo. /flow next chỉ mở khóa stage kế tiếp khi cả runner lẫn skill cùng duyệt. Các file này hình thành khi bạn vượt qua từng gate, không phải tự sinh sau khi cài.` | Replaces repetitive "cổng" with proper hierarchy: stage ghi file, runner + skill cùng duyệt, vượt qua từng gate. |
| Pipeline `aria-label` | `Idea through Contract` | `Idea through Contract` | `Sáu cổng trước khi build` | `Quy trình 6 gate từ Idea đến Contract` | Precise roadmap descriptor. |

### Section D: Stage Pipeline Taglines & Index
| Stage | Current EN Tagline | Rewritten EN Tagline | Current VI Tagline | Rewritten VI Tagline | Diagnostic Rationale |
|---|---|---|---|---|---|
| 01 Idea | `Kill bad ideas before code exists.` | `Kill bad ideas before code exists.` | `Chặn ý tưởng tồi trước khi viết code.` | `Loại ý tưởng yếu trước khi đụng vào code.` | "Loại ý tưởng yếu" sounds more professional and precise than "ý tưởng tồi". |
| 02 Research | `Cite real sources or stop here.` | `Cite real sources or stop here.` | `Trích nguồn thật hoặc dừng tại đây.` | `Dẫn nguồn thật hoặc dừng tại đây.` | "Dẫn nguồn thật" is natural Vietnamese research terminology. |
| 03 Scope | `Draw the boundary. Drop the rest.` | `Draw the boundary. Drop the rest.` | `Vạch ranh giới rõ. Bỏ hết phần thừa.` | `Vạch rõ ranh giới. Cắt bỏ phần thừa.` | Rhythmic verb-first parallel: "Vạch rõ... Cắt bỏ...". |
| 04 PRD | `Define the test before writing code.` | `Define the test before writing code.` | `Định nghĩa bài test trước khi gõ code.` | `Chốt tiêu chí test trước khi viết code.` | "Chốt tiêu chí test" is authentic Vietnamese dev slang; avoids literal "định nghĩa bài test". |
| 05 ADR | `Log the trade-off before you commit.` | `Log the trade-off before you commit.` | `Ghi lại đánh đổi trước khi commit.` | `Ghi nhận đánh đổi trước khi commit.` | "Ghi nhận" is solid and professional. |
| 06 Contract | `Both sides agree or nothing advances.` | `Both sides agree or nothing advances.` | `Cả hai cùng duyệt mới được bước tiếp.` | `Cả hai cùng duyệt mới được đi tiếp.` | "Đi tiếp" is smoother and more natural than "bước tiếp". |

### Section E: Gate 01 (Idea)
| Element | Current EN | Rewritten EN | Current VI | Rewritten VI | Diagnostic Rationale |
|---|---|---|---|---|---|
| Proof Badge Label | `FAIL · KILLED AT GATE` | `FAIL · KILLED AT GATE` | `FAIL · BỊ CHẶN TẠI CỔNG` | `FAIL · DỪNG TẠI GATE` | "Dừng tại gate" honors the principle that a stop is a valid outcome, not just a passive obstacle. |
| Proof Title | `What will not pass` | `What will not pass` | `Những gì không qua cổng` | `Những gì không qua được gate` | Uses "gate". |
| Proof Intro | `Empty, leftover [FILL], or “tests pass” offered as done. A weak idea is killed at the gate.` | `Empty, leftover [FILL], or “tests pass” offered as done. A weak idea is killed at the gate.` | `Trống, còn [FILL], hay chỉ bảo “tests pass” là chưa đủ. Ý tưởng yếu thì dừng ngay ở cổng.` | `File trống, sót token [FILL], hay chỉ nói miệng “tests pass” đều bị chặn. Ý tưởng yếu sẽ dừng ngay tại gate.` | Replaces casual "chỉ bảo... là chưa đủ" with precise "nói miệng... đều bị chặn". |
| Item 1 (`willNotPass`) | `An empty file.` | `An empty file.` | `File trống.` | `File còn để trống.` | Clear and explicit. |
| Item 2 (`willNotPass`) | `A leftover [FILL] still in the file.` | `A leftover [FILL] still in the file.` | `[FILL] còn trong file.` | `Còn sót token [FILL] chưa điền.` | Exact technical detail. |
| Item 3 (`willNotPass`) | `“Tests pass” offered as done.` | `“Tests pass” offered as done.` | `“tests pass” thế cho bằng chứng done.` | `Báo “tests pass” thay vì đưa bằng chứng done.` | Eliminates clumsy "thế cho bằng chứng". |
| Terminal Halt Line | `kill is a valid outcome.` | `kill is a valid outcome.` | `Bị chặn ở cổng thì dừng luôn, chứ không phải fail.` | `dừng ở gate là kết quả hợp lệ.` | Direct, faithful, authoritative alignment with brand brief. |
| Artifact Status Pill | `HALT` | `HALT` | `CHẶN` | `HALT` | CLI status tokens stay monospace English convention. |
| Artifact Diag Footer | `exit: 1 · unresolved [FILL] token` | `exit: 1 · unresolved [FILL] token` | `exit: 1 · phát hiện slot [FILL] chưa điền` | `exit: 1 · còn sót token [FILL] chưa điền` | Standardizes on "token [FILL]". |

### Section F: Gate 02 (Research)
| Element | Current EN | Rewritten EN | Current VI | Rewritten VI | Diagnostic Rationale |
|---|---|---|---|---|---|
| Proof Badge Label | `EVIDENCE · PRIMARY SOURCES` | `EVIDENCE · PRIMARY SOURCES` | `BẰNG CHỨNG · NGUỒN ĐỐI CHIẾU` | `BẰNG CHỨNG · NGUỒN TÀI LIỆU GỐC` | "Nguồn tài liệu gốc" accurately conveys primary source evidence. |
| Proof Title | `Ground truth before architecture` | `Ground truth before architecture` | `Thực chứng trước khi chốt kiến trúc` | `Dữ liệu thực chứng trước khi lên kiến trúc` | Clearer, more dynamic phrasing. |
| Proof Intro | `Competitor diffs, verified documentation quotes, and real failure modes recorded to repo files.` | `Competitor diffs, verified documentation quotes, and real failure modes recorded to repo files.` | `So sánh đối thủ, trích dẫn tài liệu thật và failure mode ghi lại trong file repo.` | `So sánh đối thủ, trích dẫn tài liệu thật và ghi nhận failure mode vào repo.` | Active phrasing, cleans up flow. |
| Artifact Line 1 | `## Primary sources` | `## Primary sources` | `## Nguồn đối chiếu sơ cấp` | `## Nguồn tài liệu gốc` | "Nguồn đối chiếu sơ cấp" was a heavy academic calque. |
| Artifact Line 4 | `## Competitive diff & failure modes` | `## Competitive diff & failure modes` | `## So sánh cạnh tranh & kịch bản lỗi` | `## So sánh đối thủ & các kịch bản lỗi` | Natural phrasing. |
| Artifact Diag Footer | `urls verified · ground truth locked` | `urls verified · ground truth locked` | `link đã xác thực · khóa cơ sở thực chứng` | `URL đã xác thực · chốt xong dữ liệu thực chứng` | Professional tech terminology. |
| Receipt Line 1 | `✓ 3 primary sources cited (verified URLs)` | `✓ 3 primary sources cited (verified URLs)` | `✓ 3 nguồn tài liệu gốc được kiểm chứng (URL thật)` | `✓ 3 nguồn tài liệu gốc được kiểm chứng (URL thật)` | Clean; keep. |
| Receipt Line 2 | `✓ competitive diff & failure modes locked` | `✓ competitive diff & failure modes locked` | `✓ so sánh đối thủ & failure modes đã khoá` | `✓ phân tích đối thủ & failure mode đã khóa` | Natural phrasing. |

### Section G: Gate 03 (Scope)
| Element | Current EN | Rewritten EN | Current VI | Rewritten VI | Diagnostic Rationale |
|---|---|---|---|---|---|
| Proof Badge Label | `PERIMETER · NON-GOALS` | `PERIMETER · NON-GOALS` | `BIÊN GIỚI · PHI MỤC TIÊU` | `RANH GIỚI · NON-GOALS` | "Biên giới" means international border; "phi mục tiêu" is bizarre. Non-goals is standard. |
| Proof Title | `Explicit non-goals frozen` | `Explicit non-goals frozen` | `Khoá cứng phần ngoài phạm vi` | `Khóa cứng danh sách non-goals` | Accurate dev vernacular. |
| Proof Intro | `Bounded delivery slices. Scope creep is caught before any code generation begins.` | `Bounded delivery slices. Scope creep is caught before any code generation begins.` | `Chia nhỏ các phần việc khả thi. Ngăn tình trạng phình phạm vi trước khi sinh code.` | `Gói gọn từng phần việc bàn giao. Chặn đứng scope creep trước khi agent bắt đầu sinh code.` | "Phần việc bàn giao" > "lát cắt"; "scope creep" is universal among devs. |
| Artifact Line 1 | `IN-SCOPE S-01 CLI harness gate loop` | `IN-SCOPE S-01 CLI harness gate loop` | `TRONG-PHẠM-VI S-01 Vòng lặp cổng CLI` | `TRONG-PHẠM-VI S-01 Vòng lặp gate CLI` | Uses "gate". |
| Artifact Line 4 | `NON-GOAL Custom cloud daemon runtime` | `NON-GOAL Custom cloud daemon runtime` | `NGOÀI-PHẠM-VI Daemon đám mây riêng biệt` | `NGOÀI-PHẠM-VI Daemon đám mây riêng` | Removes awkward "biệt". |
| Artifact Diag Footer | `2 deliverable slices · perimeter frozen` | `2 deliverable slices · perimeter frozen` | `2 lát cắt bàn giao · khóa ranh giới phạm vi` | `2 phần việc bàn giao · ranh giới đã khóa` | Purges "lát cắt bàn giao". |
| Receipt Line 1 | `✓ 3 deliverable slices locked` | `✓ 3 deliverable slices locked` | `✓ 3 lát cắt bàn giao được khoá` | `✓ 3 phần việc bàn giao đã khóa` | Purges "lát cắt". |
| Receipt Line 2 | `✓ non-goals explicitly frozen (scope creep blocked)` | `✓ non-goals explicitly frozen (scope creep blocked)` | `✓ phi mục tiêu được đóng băng (chặn scope creep)` | `✓ non-goals đã khóa cứng (chặn đứng scope creep)` | Purges "phi mục tiêu được đóng băng". |

### Section H: Gate 04 (PRD)
| Element | Current EN | Rewritten EN | Current VI | Rewritten VI | Diagnostic Rationale |
|---|---|---|---|---|---|
| Proof Badge Label | `CONTRACT · ACCEPTANCE` | `CONTRACT · ACCEPTANCE` | `HỢP ĐỒNG · TIÊU CHÍ NGHIỆM THU` | `CAM KẾT · TIÊU CHÍ NGHIỆM THU` | "Cam kết" reflects the binding nature of acceptance criteria. |
| Proof Title | `Observable criteria only` | `Observable criteria only` | `Chỉ chấp nhận tiêu chí quan sát được` | `Chỉ chấp nhận tiêu chí kiểm chứng được` | In testing, criteria are verified/tested, not merely observed with eyes. |
| Proof Intro | `User stories with testable invariants. The agent cannot redefine success mid-flight.` | `User stories with testable invariants. The agent cannot redefine success mid-flight.` | `User stories với các bất biến kiểm thử được. Agent không thể tự đổi định nghĩa done giữa chừng.` | `User stories đi kèm điều kiện bất biến kiểm thử được. Agent không thể tự ý đổi định nghĩa done giữa chừng.` | Smooth connective phrasing. |
| Artifact Line 4 | `INV-04: degraded mode creates debt entry` | `INV-04: degraded mode creates debt entry` | `INV-04: chế độ degrade tự mở khoản nợ kỹ thuật` | `INV-04: chế độ degrade tự ghi nhận technical debt` | Replaces financial banking calque "mở khoản nợ" with standard "technical debt". |
| Artifact Diag Footer | `4 observable invariants · 0 prose fluff` | `4 observable invariants · 0 prose fluff` | `4 bất biến kiểm chứng được · không văn mơ hồ` | `4 điều kiện bất biến kiểm chứng được · 0 từ ngữ mơ hồ` | Concrete count format ("0 từ ngữ..."). |
| Receipt Line 1 | `✓ observable acceptance criteria specified` | `✓ observable acceptance criteria specified` | `✓ tiêu chí nghiệm thu quan sát được đã xác nhận` | `✓ tiêu chí nghiệm thu kiểm chứng được đã xác nhận` | "Kiểm chứng được" > "quan sát được". |
| Receipt Line 2 | `✓ error states & degraded paths defined` | `✓ error states & degraded paths defined` | `✓ trạng thái lỗi & phương án suy thoái đã định nghĩa` | `✓ trạng thái lỗi & luồng xử lý degrade đã xác định` | **Crucial fix.** Purges absurd "phương án suy thoái" (economic recession) for degraded mode! |

### Section I: Gate 05 (ADR)
| Element | Current EN | Rewritten EN | Current VI | Rewritten VI | Diagnostic Rationale |
|---|---|---|---|---|---|
| Proof Badge Label | `DECISION · TRADE-OFFS` | `DECISION · TRADE-OFFS` | `QUYẾT ĐỊNH · ĐÁNH ĐỔI` | `QUYẾT ĐỊNH · ĐÁNH ĐỔI` | Strong and natural; keep. |
| Proof Title | `Architecture Decision Records` | `Architecture Decision Records` | `Bản ghi quyết định kiến trúc` | `Bản ghi quyết định kiến trúc` | Standard industry term; keep. |
| Proof Intro | `Context, decision, and consequences recorded before implementation starts.` | `Context, decision, and consequences recorded before implementation starts.` | `Bối cảnh, quyết định và hệ quả được ghi chép trước khi triển khai.` | `Ghi nhận bối cảnh, quyết định và hệ quả trước khi bắt đầu code.` | Active voice, dev-practical "bắt đầu code" instead of abstract "triển khai". |
| Artifact Line 4 | `Consequence: Portable; zero background server` | `Consequence: Portable; zero background server` | `Hệ quả: Di động tuyệt đối; không cần daemon ngầm` | `Hệ quả: Portable; không cần background server` | "Di động tuyệt đối" was a ridiculous calque for portable software! |
| Artifact Diag Footer | `reversibility mapped · trade-off locked` | `reversibility mapped · trade-off locked` | `đã lập bản đồ hoàn tác · chốt xong đánh đổi` | `đã tính đường lùi · chốt xong đánh đổi` | "Lập bản đồ hoàn tác" was a literal map translation. "Tính đường lùi" is expressive dev idiom. |
| Receipt Line 1 | `✓ context, decision, consequences documented` | `✓ context, decision, consequences documented` | `✓ bối cảnh, quyết định, hệ quả đã ghi chép` | `✓ bối cảnh, quyết định và hệ quả đã ghi nhận` | Professional tone. |
| Receipt Line 2 | `✓ reversibility & negative test cases mapped` | `✓ reversibility & negative test cases mapped` | `✓ khả năng hoàn tác & ca kiểm thử âm đã đối chiếu` | `✓ khả năng rollback & kịch bản kiểm thử lỗi đã đối chiếu` | **Crucial fix.** Purges medical "ca kiểm thử âm" for negative test cases; uses "rollback" and "kiểm thử lỗi". |

### Section J: Gate 06 (Contract)
| Element | Current EN | Rewritten EN | Current VI | Rewritten VI | Diagnostic Rationale |
|---|---|---|---|---|---|
| Proof Badge Label | `PASS · READY` | `PASS · READY` | `PASS · SẴN SÀNG` | `PASS · SẴN SÀNG` | Clean status; keep. |
| Proof Title | `After install` | `After install` | `Cài xong` | `Sau khi cài đặt` | Professional phrasing. |
| Proof Intro | `The skill is on disk. /flow or $flow exists. doctor can print READY. /flow next on an empty idea file refuses with line numbers.` | `The skill is on disk. /flow or $flow exists. doctor can print READY. /flow next on an empty idea file refuses with line numbers.` | `Skill nằm trên ổ đĩa. /flow hoặc $flow dùng được. doctor in READY. /flow next trên file idea trống thì từ chối kèm số dòng.` | `Skill đã sẵn sàng trên máy. Lệnh /flow hoặc $flow đã nhận. flow doctor in READY. Gõ /flow next trên file idea trống sẽ báo lỗi kèm số dòng.` | Smooth, clear verification narrative. |
| Item 1 (`afterInstall`) | `Skill files land in the agent home.` | `Skill files land in the agent home.` | `Skill nằm trong agent home.` | `File skill nằm gọn trong thư mục của agent.` | Specific, reassuring. |
| Item 2 (`afterInstall`) | `Type /flow (Codex: $flow).` | `Type /flow (Codex: $flow).` | `Gõ /flow (Codex: $flow).` | `Gõ /flow trong chat (Codex: $flow).` | Highlights chat-first usage. |
| Item 3 (`afterInstall`) | `doctor can print READY.` | `doctor can print READY.` | `doctor in READY.` | `Lệnh doctor in ra READY.` | Clear. |
| Item 4 (`afterInstall`) | `/flow next on an empty idea file refuses with line numbers.` | `/flow next on an empty idea file refuses with line numbers.` | `/flow next trên thư mục trống thì cổng chặn.` | `/flow next trên file idea trống sẽ từ chối và chỉ rõ số dòng.` | **Crucial fix.** Current VI mistranslated "empty idea file refuses with line numbers" into "thư mục trống thì cổng chặn"! Restores accuracy. |
| Artifact Status Pill | `UNLOCKED` | `UNLOCKED` | `MỞ CỔNG` | `UNLOCKED` | Keep standard CLI token. |
| Artifact Line 1 | `[✓] human-signoff: approved by @dev` | `[✓] human-signoff: approved by @dev` | `[✓] người-duyệt: @dev đã chấp thuận` | `[✓] dev-xác-nhận: @dev đã duyệt` | Natural dev jargon ("đã duyệt"). |
| Artifact Line 4 | `[✓] dual-agreement: UNLOCKED -> advance` | `[✓] dual-agreement: UNLOCKED -> advance` | `[✓] đồng-thuận-kép: MỞ CỔNG -> tiến hành build` | `[✓] xác-nhận-kép: UNLOCKED -> tiến hành build` | Cleaner token. |
| Artifact Diag Footer | `signed contract · gate cleared for build` | `signed contract · gate cleared for build` | `hợp đồng đã ký · cổng mở cho giai đoạn build` | `hợp đồng đã ký · gate đã mở cho giai đoạn build` | Uses "gate". |
| Terminal Receipt Line | `The gate opens only when both agree.` | `The gate opens only when both agree.` | `Cổng chỉ mở khi cả hai bên cùng đồng ý.` | `Gate chỉ mở khi cả hai cùng duyệt.` | Matches revised hero verdict line. |

### Section K: Post-Gates Band Foot & CTA Stand Section
| Key / Location | Current EN | Rewritten EN | Current VI | Rewritten VI | Diagnostic Rationale |
|---|---|---|---|---|---|
| Band Foot Note | `Then /flow card. Done means proof in the world: a deployed URL, a CLI that installs and runs, a public API, or a real skill run.` | `Then /flow card. Done means proof in the world: a deployed URL, a CLI that installs and runs, a public API, or a real skill run.` | `Xong thì /flow card. Xong nghĩa là có bằng chứng thật: một URL đã deploy, một CLI cài chạy được, một public API, hay một lần chạy skill thật.` | `Tiếp theo là /flow card. Done phải có bằng chứng thực tế: một URL đang chạy, một CLI cài đặt và chạy được, một public API, hay một lần chạy skill thật.` | Replaces repetitive "Xong thì... Xong nghĩa là" with structured "Tiếp theo là... Done phải có". |
| Stand Title (`<h2>`) | `Not an AI coding agent. A harness around one.` | `Not an AI coding agent. A harness around one.` | `Không phải AI coding agent. Là cổng kiểm soát quanh agent.` | `Không phải một coding agent. Đây là harness giữ kỷ luật cho agent.` | "Cổng kiểm soát quanh agent" is clumsy; "harness giữ kỷ luật cho agent" hits brand core: discipline layer. |
| Stand Paragraph | `flow does not write your code. The agent still writes; the harness decides whether that work may advance.` | `flow does not write your code. The agent still writes; the harness decides whether that work may advance.` | `flow không tự viết code. Agent vẫn viết, flow chỉ quyết việc có được qua cổng hay không.` | `flow không tự viết code. Agent vẫn viết; harness quyết định xem phần việc đó có đủ tiêu chuẩn để đi tiếp hay không.` | Elevates conversational doorman phrasing into professional engineering verdict. |
| Stand Primary Action | `Install and first run` | `Install and first run` | `Cài rồi chạy thử` | `Cài đặt và lần chạy đầu` | Standardizes CTA. |
| Stand Secondary Action | `Read the docs` | `Read the docs` | `Đọc tài liệu` | `Đọc tài liệu` | Clean; keep. |

### Section L: Colophon / Footer (`Colophon.astro`)
| Key / Location | Current EN | Rewritten EN | Current VI | Rewritten VI | Diagnostic Rationale |
|---|---|---|---|---|---|
| Imprint Line | `flow — a gated build harness for coding agents.` | `flow — a gated build harness for coding agents.` | `flow — cổng cho agent viết code.` | `flow — harness kiểm soát bằng gate cho coding agent.` | **Glaring issue.** "Cổng cho agent viết code" meant "a portal for agents to write code", distorting the entire product definition. |
| Footer Tagline | `Proof over vibes.` | `Proof over vibes.` | `Bằng chứng hơn cảm hứng.` | `Bằng chứng hơn cảm hứng.` | Brand tagline #1 invariant; keep. |

---

## 7. Implementation Checklist & Verification Gates

- [x] Create research copy deck at `plans/research/copy-deck.md`.
- [ ] Create git branch `feat/copy-refresh` from `master`.
- [ ] Apply copy edits to `website/src/pages/index.astro`.
- [ ] Apply copy edits to `website/src/pages/vi/index.astro`.
- [ ] Apply copy edits to `website/src/components/Colophon.astro` (imprint line).
- [ ] Ensure strict element parity (zero structural/CSS diffs; only text node changes).
- [ ] Run verification scripts:
  - `bash scripts/check-i18n-pairs.sh`
  - `bash scripts/check-doc-budgets.sh`
  - `(cd website && npm run build)`
- [ ] Grep `website/dist/` to verify that new copy strings render in built HTML without hydration issues.
- [ ] Push branch `feat/copy-refresh` to `origin`.
