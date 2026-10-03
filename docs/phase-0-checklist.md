# Phase 0 And Phase 1 Acceptance Checklist

Đánh dấu từng mục bằng bằng chứng cụ thể: command output, ảnh Horizon hoặc video ngắn. Không coi tài liệu là bằng chứng cho tới khi lệnh thực tế chạy thành công.

## Phase 0 VMware and Ubuntu

- [ ] Ubuntu Server VM cài riêng trong VMware Fusion.
- [ ] VM có 4 vCPU, RAM phù hợp và ít nhất 80 GB disk.
- [ ] Bridged network đã chọn hoặc đã ghi rõ lý do dùng NAT.
- [ ] Ubuntu có IP ổn định hoặc DHCP reservation.
- [ ] Từ máy phát triển ping/SSH được vào Ubuntu VM.
- [ ] Nested virtualization đã bật và được ghi nhận.
- [ ] User `stack` chạy được sudo không cần password.
- [ ] `./scripts/verify-host.sh` chạy không còn mục bắt buộc bị thiếu.

## Phase 1 DevStack

- [ ] Đã chốt Ubuntu version và DevStack branch.
- [ ] `local.conf` được tạo riêng trong `/opt/stack/devstack` và không commit.
- [ ] `./stack.sh` hoàn thành không có lỗi fatal.
- [ ] Horizon mở được từ máy phát triển.
- [ ] `source openrc admin admin` thành công.
- [ ] `openstack token issue` thành công.
- [ ] `openstack service list` hiển thị Keystone, Nova, Neutron, Glance và Horizon.
- [ ] Có image Ubuntu cloud image.
- [ ] Có flavor `small` và `medium`.
- [ ] Có network private và security group `portal-ssh`.
- [ ] Tạo được `demo-vm`.
- [ ] `demo-vm` chuyển `BUILD` sang `ACTIVE`.
- [ ] Có console log hoặc SSH chứng minh guest boot thành công.
- [ ] Đã chụp VMware snapshot sau khi DevStack hoạt động.

## Integration from portal machine

- [ ] Đã tạo `.venv` và cài `requirements.txt`.
- [ ] `clouds.yaml` nằm ngoài Git và permission là `600`.
- [ ] `OS_CLIENT_CONFIG_FILE` trỏ đúng file.
- [ ] `openstack --os-cloud portal token issue` chạy từ máy portal.
- [ ] App chạy được ở `OPENSTACK_MODE=mock`.
- [ ] App chuyển được sang `OPENSTACK_MODE=real` mà không lộ credential.
- [ ] `git status` không hiển thị `.env`, `clouds.yaml`, image hoặc VM artifact.

## Bằng chứng cần lưu

- Ảnh cấu hình VMware.
- Ảnh IP Ubuntu và `verify-host.sh`.
- Log thành công của `stack.sh`.
- Ảnh Horizon.
- Output `token issue`, `service list`, `image list`, `flavor list`, `network list`.
- Output `server show demo-vm` và ảnh trạng thái `ACTIVE`.
- Video backup ngắn cho buổi demo.
