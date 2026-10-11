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

## Kịch bản demo giữa kỳ bằng Mac và UTM Ubuntu

Mục tiêu demo:

```text
MacBook
└── UTM Ubuntu VM
    └── DevStack/OpenStack
        └── Python openstacksdk gọi trực tiếp OpenStack API
```

Tất cả lệnh bên dưới chạy **trong Terminal của Ubuntu VM**, không chạy trong Terminal macOS. MacBook chỉ dùng để mở UTM và hiển thị màn hình demo.

### Chuẩn bị trước giờ demo

Chỉ cần làm một lần trước buổi bảo vệ:

```bash
cd ~/cloud-portal-billing
git pull origin main

python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt

cd /opt/stack/devstack
source openrc admin admin
```

Kiểm tra nhanh trước buổi demo:

```bash
openstack token issue
openstack compute service list
openstack network agent list
openstack image list
openstack flavor list
openstack network list
```

Các tài nguyên đang có trong môi trường demo hiện tại:

```text
Image: cirros-0.6.3-x86_64-disk
Flavor: m1.tiny, m1.small, m1.medium, ...
Network: private, public, shared
```

### Kịch bản trình diễn chính

#### 1. Mở môi trường cloud

```bash
hostname -I
cd /opt/stack/devstack
source openrc admin admin
```

#### 2. Chứng minh xác thực với Keystone

```bash
openstack token issue
```

Nói với hội đồng: “Portal/SDK có thể xác thực trực tiếp với Keystone của OpenStack.”

#### 3. Chứng minh các service đang hoạt động

```bash
openstack service list
openstack compute service list
openstack network agent list
```

Kết quả cần thấy các service/agent ở trạng thái `enabled`, `up` hoặc `UP`.

#### 4. Chứng minh OpenStack có tài nguyên để cấp VM

```bash
openstack image list
openstack flavor list
openstack network list
```

#### 5. Chạy demo Python SDK read-only

```bash
cd ~/cloud-portal-billing
source .venv/bin/activate
source /opt/stack/devstack/openrc admin admin

./scripts/phase1_demo.sh
```

Kết quả cần có:

```text
AUTHENTICATION: OK
CONNECTION: Python openstacksdk -> OpenStack API
PHASE 1 RESULT: PASS
```

Đây là phần chứng minh trực tiếp bằng Python, không chỉ dùng Horizon hay thao tác thủ công.

#### 6. Tùy chọn tạo VM để demo end-to-end

Nếu muốn cho hội đồng thấy OpenStack thực sự tạo VM:

```bash
cd /opt/stack/devstack
source openrc admin admin

openstack server create demo-vm \
  --image cirros-0.6.3-x86_64-disk \
  --flavor m1.tiny \
  --network private
```

Theo dõi trạng thái:

```bash
watch -n 3 'openstack server show demo-vm -f value -c status'
```

Kết quả cần chuyển từ:

```text
BUILD
ACTIVE
```

Khi đã `ACTIVE`, hiển thị chi tiết:

```bash
openstack server show demo-vm
openstack server list
```

Nếu cần xem log khởi động:

```bash
openstack console log show demo-vm | tail -n 50
```

#### 7. Đối chiếu trên Horizon

Lấy IP Ubuntu VM:

```bash
hostname -I
```

Mở trình duyệt trong Ubuntu hoặc trên Mac nếu mạng cho phép:

```text
http://IP_UBUNTU_VM/dashboard
```

Đăng nhập bằng tài khoản `admin` và mở `Compute → Instances`. VM `demo-vm` phải xuất hiện ở trạng thái `Active`.

#### 8. Dọn VM sau demo

Nếu không cần giữ VM:

```bash
openstack server delete demo-vm
```

### Chuỗi lệnh ngắn nhất để demo

Nếu đã chuẩn bị sẵn mọi thứ, chỉ cần chạy:

```bash
cd ~/cloud-portal-billing
source .venv/bin/activate
source /opt/stack/devstack/openrc admin admin
./scripts/phase1_demo.sh

openstack server create demo-vm \
  --image cirros-0.6.3-x86_64-disk \
  --flavor m1.tiny \
  --network private

watch -n 3 'openstack server show demo-vm -f value -c status'
```

Kịch bản này chứng minh đầy đủ:

```text
Keystone authentication
→ OpenStack service health
→ Python SDK direct connection
→ Image/flavor/network discovery
→ Nova creates a real VM
→ VM becomes ACTIVE
```

Nếu chỉ cần chứng minh kết nối direct theo yêu cầu giữa kỳ, dừng sau `PHASE 1 RESULT: PASS`. Bước tạo `demo-vm` là phần bổ sung để demo thuyết phục hơn.

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
