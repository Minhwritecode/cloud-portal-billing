# Cloud Portal

Đồ án xây dựng cổng dịch vụ Cloud tự phục vụ trên OpenStack. Repository hiện được chuẩn bị theo hướng **setup hạ tầng trước, viết tính năng sau**.

## Trạng thái hiện tại

Phase 1 đã được nghiệm thu trên Ubuntu VM chạy DevStack:

- `phase1_demo.sh`: `PHASE 1 RESULT: PASS`.
- Python `openstacksdk` xác thực thành công với OpenStack API.
- Có image CirrOS ở trạng thái `ACTIVE`.
- Có các flavor và network `shared`, `public`, `private`.
- `nova-compute`, Neutron OVN agents đang `UP`.
- Chưa có server nào được tạo (`SERVERS (0)` là bình thường ở bước kết nối).

Trạng thái chạy trong VM, password, database, image, network và token không được lưu trong Git.

## Mục tiêu của project base

- Chạy DevStack All-in-One trên Ubuntu VM riêng trong VMware Fusion.
- Kết nối được từ máy phát triển tới OpenStack qua `clouds.yaml`.
- Có thể kiểm tra Keystone, Nova, Neutron, Glance, Horizon và tạo VM mẫu.
- Giữ credential ngoài Git.
- Có checklist nghiệm thu theo từng phase trước khi bắt đầu portal và billing.

## Cấu trúc setup

```text
cloud-portal/
├── docs/
│   ├── phase-0-setup.md          # VMware, Ubuntu, DevStack, networking
│   └── phase-0-checklist.md      # tiêu chí nghiệm thu hạ tầng
├── infra/
│   ├── devstack/local.conf.example
│   └── openstack/clouds.yaml.example
├── scripts/
│   ├── verify-devstack.sh
│   └── verify-host.sh
├── openstack_client/             # SDK wrapper, sẽ phát triển ở phase sau
├── billing/                      # billing, sẽ phát triển ở phase sau
└── tests/
```

## Bắt đầu từ đâu

Đọc và thực hiện theo thứ tự:

1. [`docs/phase-0-setup.md`](docs/phase-0-setup.md)
2. [`docs/phase-0-checklist.md`](docs/phase-0-checklist.md)
3. [`infra/devstack/local.conf.example`](infra/devstack/local.conf.example)
4. [`infra/openstack/clouds.yaml.example`](infra/openstack/clouds.yaml.example)

Chỉ bắt đầu code portal sau khi toàn bộ Phase 0 và Phase 1 trong checklist đã đạt.

## Demo Phase 1

Sau khi DevStack chạy và đã xác thực bằng `openrc`, nhóm có thể chạy bộ demo read-only:

```bash
cd ~/cloud-portal-billing
chmod +x scripts/phase1_demo.sh
./scripts/phase1_demo.sh
```

Script này kiểm tra token, service, compute, network, image, flavor, server và kết nối Python SDK. Nó không tạo hoặc xóa tài nguyên.

## Làm việc nhóm với một OpenStack VM dùng chung

Git chỉ đồng bộ source code và script. `git clone` **không** sao chép trạng thái Ubuntu VM, DevStack, database OpenStack, image, network, server, password hay token. Vì vậy, clone repository trên máy thành viên không tự làm máy đó có OpenStack.

Với nhóm 4 người, cách đơn giản nhất là dùng một VM DevStack làm máy chủ tích hợp:

```text
Máy của thành viên A        Máy của bạn
Project + openstacksdk ───► Ubuntu VM + DevStack/OpenStack
                              └── Keystone/Nova/Neutron/Glance
```

### Máy chủ DevStack của bạn

Giữ UTM/Ubuntu VM đang chạy và lấy IP của VM:

```bash
hostname -I
```

Ví dụ:

```text
192.168.1.120
```

Máy thành viên phải truy cập được OpenStack API:

```bash
curl -i http://192.168.1.120/identity/v3
```

Nếu không truy cập được, kiểm tra UTM network mode. Bridged networking thường thuận tiện hơn cho các máy cùng LAN. Nếu nhóm làm từ các mạng khác nhau, cần VPN như Tailscale/ZeroTier hoặc port forwarding an toàn; không mở OpenStack trực tiếp ra Internet.

### Máy của thành viên nhóm

Thành viên clone repository một lần:

```bash
git clone https://github.com/Minhwritecode/cloud-portal-billing.git
cd cloud-portal-billing
```

Cài môi trường Python:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

Tạo credential file riêng ngoài repository:

```bash
mkdir -p ~/.config/openstack
cp infra/openstack/clouds.yaml.example ~/.config/openstack/clouds.yaml
chmod 600 ~/.config/openstack/clouds.yaml
```

Trong `~/.config/openstack/clouds.yaml`, thay `CHANGE_ME_VM_IP` bằng IP Ubuntu VM của bạn và điền credential lab được nhóm thống nhất. Không gửi password qua Git hoặc commit file này.

Test từ máy thành viên:

```bash
export OS_CLIENT_CONFIG_FILE="$HOME/.config/openstack/clouds.yaml"
export OS_CLOUD=portal
export OPENSTACK_CLOUD=portal

openstack --os-cloud portal token issue
./scripts/phase1_demo.sh
```

Nếu thành công, thành viên đang gọi trực tiếp OpenStack VM của bạn qua API; họ không cần cài DevStack riêng. Trong môi trường production không dùng chung tài khoản `admin`; hãy cấp credential/project riêng cho từng người. Tài khoản `admin` chỉ dùng để setup và kiểm tra hạ tầng.

### Khi nào thành viên cần VM riêng?

Nếu muốn mỗi người tự chạy OpenStack độc lập khi máy chủ của bạn tắt, mỗi người phải tự có:

1. VMware/UTM.
2. Ubuntu VM riêng.
3. DevStack riêng.
4. `local.conf` riêng với `HOST_IP` và password riêng.
5. Image, flavor, network và credential riêng.

Khi đó thành viên làm theo [`docs/phase-0-setup.md`](docs/phase-0-setup.md). Repository chỉ cung cấp template và script; nó không thể tái tạo toàn bộ trạng thái OpenStack hiện tại bằng `git clone`.

### Quy trình cập nhật code của nhóm

```bash
cd ~/cloud-portal-billing
git pull origin main
```

Sau mỗi lần cập nhật, chạy lại:

```bash
source .venv/bin/activate
./scripts/phase1_demo.sh
```

Khi máy chủ DevStack tắt, thành viên vẫn có thể phát triển giao diện và logic bằng:

```dotenv
OPENSTACK_MODE=mock
```

Khi cần integration test thật, bật VM DevStack và dùng:

```dotenv
OPENSTACK_MODE=real
OPENSTACK_CLOUD=portal
```

## Môi trường ứng dụng sau khi OpenStack sẵn sàng

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
cp .env.example .env
pytest -q
```

Health check hiện tại:

```bash
python run.py
curl http://127.0.0.1:8000/health
```

## Hai chế độ kết nối

- `OPENSTACK_MODE=mock`: dùng cho phát triển app khi DevStack tắt.
- `OPENSTACK_MODE=real`: dùng `openstacksdk` và named cloud trong `clouds.yaml`.

Không commit `.env`, `clouds.yaml`, password, token, private key, file image hoặc file máy ảo lên Git.

## Ghi chú quan trọng

DevStack là môi trường development/test, không phải production. DevStack phải chạy trên Ubuntu VM riêng vì quá trình cài đặt thay đổi đáng kể hệ thống. Cấu hình VMware và DevStack trong repository là template; các giá trị như IP, interface và password phải được điền theo mạng thực tế của nhóm.

## Quy trình Git

```bash
git checkout -b feature/ten-tinh-nang
git add .
git commit -m "feat: mo ta thay doi"
git push -u origin feature/ten-tinh-nang
```

Mọi thay đổi nên đi qua Pull Request trước khi merge vào `main`.
