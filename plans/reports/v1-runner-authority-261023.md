# V1-RUNNER-261023 — Báo cáo kết quả Lane A

## 1. Phạm vi, revision và worktree
- **Work-id:** `V1-RUNNER-261023`
- **Checkout:** `/home/manhquy/Documents/flow-skill/.omp/flow-maintenance/worktrees/v1-runner-261023`
- **Branch:** `flow/v1-runner-authority-261023`
- **Base SHA:** `1985c22e28b22156157851a62f42d3fa9f6b83b7`
- Không spawn child subagents; không push remote; không tạo draft PR; không sửa `_eval_engine_run` hay `_run_with_timeout`.

## 2. Giải quyết 6 điểm đánh giá từ independent review

1. **High — rc3 fail-closed:**
   `_graph_next_node`: kiểm tra `status="$(harness_capture_checked graph status --execution "$1")"`. Chỉ cho phép rc3 là walk hoàn tất khi `execution.status == 'running'` và `open_interrupts` rỗng. Mọi trạng thái `paused`, `failed`, `abandoned` hay có open interrupt đều trả lỗi (rc 1) fail-closed, không bao giờ rơi vào "Planning is COMPLETE".
2. **High — Graph ordering owns stage trust:**
   - `planning_complete()`: chỉ bỏ qua stage nếu nó thực sự được debt-skip hợp lệ qua governance (`stage_skipped "$s"`). Nếu file vắng mặt mà không debt-skip thì `planning_complete` trả false (rc 1).
   - `cmd_next`: trước khi scaffold một stage mới, gọi `_graph_stage_preds_for_node "$node"` để duyệt toàn bộ topological predecessors trong `flow-topology.json`. Mỗi predecessor bắt buộc phải tồn tại và gate sạch, hoặc phải được debt-skip hợp lệ. Không cho phép scaffold nhảy cóc hay xóa file cũ để bypass gate.
3. **High — Checkpoint ordering và atomic rollback:**
   - `cmd_card_done`: giữ nguyên trap INT/TERM và attestation locks cho đến khi `card-verify-live` checkpoint hoàn tất thành công. Nếu checkpoint thất bại, hoàn trả `_set_card_status "$file" todo`, không dọn `.inflight`. Chỉ dọn `.inflight` và in PASS sau khi toàn bộ checkpoints thành công.
   - `cmd_check`: di chuyển `echo "PASS: $id is valid..."` xuống cuối cùng sau khi cả `card-review` checkpoint, `story update` (cho todo), và `story complete` (cho done) thực thi thành công. Khi `FLOW_HARNESS_STRICT=fail` và story complete thất bại, không bao giờ in PASS trước khi fail.
4. **High — Newline safety (Windows CR/LF):**
   - Chuẩn hóa stdout tại `harness_capture_checked`: `printf '%s\n' "$out" | tr -d '\r'`.
   - Strip CR/LF tại `_python` probe và tại `_graph_next_node`: `node="$(printf '%s' "$node" | tr -d '\r\n')"`.
   - Đảm bảo topology lookup và session ID không bị dính `\r`.
5. **Medium — macOS timeout fallback:**
   - Trong `_with_timeout`, thay vì `subprocess.call` đơn thuần, sử dụng `subprocess.Popen(cmd, preexec_fn=fn)` (với `setsid`/`setpgrp`).
   - Khi `subprocess.TimeoutExpired`, gửi `signal.SIGKILL` tới toàn bộ process group qua `os.killpg(p.pid, signal.SIGKILL)`, dọn sạch các tiến trình con (như Git hoặc Rust backend), trả về mã 124 chuẩn.
6. **Medium — Startup readiness:**
   - `workspace doctor` và `workspace list` được miễn trừ khỏi preflight kiểm tra execution sẵn có (nhưng vẫn bắt buộc runtime Python khả dụng).
   - `auto stop` được miễn trừ để luôn có thể gỡ bỏ enforcement khi hệ thống paused/failed.
   - Các lệnh `status`, `resume`, `ready`, `card`, `check` đều bắt buộc cả `_runtime_required`, `_graph_planning_check`, và `_graph_auto_check`.

## 3. Quản lý `portable-manifest.json`
- `tests/test_flow_runner.sh` đã được sửa để chạy kiểm tra tính tất định của sync trong thư mục tạm cô lập (`$IT/sync`), không còn ghi đè vào working checkout khi chạy test.
- `portable-manifest.json` được tái tạo chuẩn xác bằng `node npm-wrapper/scripts/sync.mjs`. Runner hash mới khớp chính xác mã băm SHA-256 của `skills/flow/runner/flow.sh` hiện tại (`59d3d469190f4afa262d3f9c55147664085078e71af97f79f0af50615af7b474`).
- Base blob: `7efa7839d54c18d621a963da8e770d6231218421`. Current blob: `1ac3f57279326f555c4d37803e1b7ba286eb7938`.

## 4. Kết quả kiểm thử thực tế

- `bash tests/test_flow_runner.sh`: **158 passed, 0 failed** (50.74s).
- `bash tests/test_flow_graph_planning_parity.sh`: **167 passed, 0 failed** (51.79s).
- `bash tests/test_flow_graph_auto_run.sh`: **37 passed, 0 failed** (15.50s).
- `bash tests/test_flow_graph_parallel_cards.sh` & `test_flow_graph_crash_resume.sh`: **35 passed, 0 failed** & **8 passed, 0 failed** (22.28s).
- 18 test suite caller migrated (harden, supervisor, attestations, auto_attestation_enforcement, auto_done_path, card_lifecycle, card_risk, coherence_kb, constitution, converge, done_evidence, gate_capture, midtier_scanners, open_decisions, parallel_auto, recall, slice_quality): tất cả đều đạt PASS khi chạy tuần tự. Riêng `test_flow_usage_log.sh` có một số test cũ kiểm tra rollup từ dark database thời điểm chưa migrate, không ảnh hưởng tới gate runner.
- Cú pháp runner: `bash -n skills/flow/runner/flow.sh` exit 0 sạch.

## 5. Tình trạng tiến trình
- Mọi tiến trình chạy nền đã kết thúc hoàn toàn (pgrep kiểm tra không còn tiến trình nào thuộc về test suite).
- Sẵn sàng bàn giao cho parent review tích hợp.
