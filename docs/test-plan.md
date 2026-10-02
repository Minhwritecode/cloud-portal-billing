# Test Plan

## Phase 1 Infrastructure

- OpenStack token issue thành công.
- Có image, flavor, network.
- Tạo được VM bằng CLI.
- VM chuyển `BUILD` sang `ACTIVE`.
- SSH được vào VM.

## Phase 2 SDK

- Kết nối được bằng `openstacksdk`.
- Lấy được image và flavor.
- Tạo, start, stop và delete VM.
- Xử lý timeout và lỗi API.

## Phase 3 Portal

- Login.
- Tạo VM.
- Hiển thị trạng thái.
- Chỉ thấy VM của chính user.

## Phase 4 Billing

- Tính phí `ACTIVE`.
- Tính phí `SHUTOFF` theo tỷ lệ đã thống nhất.
- Không tính phí `BUILD` và `ERROR`.
- Không tạo transaction trùng khi worker chạy lại.
