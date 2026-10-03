# Phase 0 Setup Environment

Tài liệu này thiết lập hạ tầng nền trước khi nhóm viết Web Portal và Billing. Mục tiêu cuối cùng là máy phát triển có thể xác thực tới OpenStack VM và nhóm có thể tạo một VM mẫu bằng OpenStack CLI.

## 1. Mô hình máy

```text
MacBook Intel 2019
└── VMware Fusion
    └── Ubuntu Server VM
        └── DevStack All-in-One
            ├── Keystone
            ├── Nova
            ├── Neutron
            ├── Glance
            ├── Cinder
            └── Horizon

Máy phát triển khác ── LAN/Tailscale ── Ubuntu VM ── OpenStack API
```

DevStack là môi trường phát triển/kiểm thử và thay đổi đáng kể hệ điều hành. Chỉ chạy nó trên Ubuntu VM riêng, không chạy trực tiếp trên macOS hoặc một máy đang chứa dữ liệu quan trọng.

## 2. Cấu hình VMware Fusion

Khuyến nghị ban đầu cho MacBook 16 GB RAM:

| Thành phần | Giá trị |
|---|---|
| Guest OS | Ubuntu Server 24.04 LTS 64-bit |
| vCPU | 4 cores |
| RAM | 8 GB; dùng 10–12 GB nếu Mac có 32 GB RAM |
| Disk | 80 GB tối thiểu, nên dùng 100 GB |
| Network | Bridged Networking |
| Firmware | UEFI mặc định |
| Snapshot | Chụp snapshot sau Ubuntu sạch và sau DevStack thành công |
| Shared folders | Tắt trong lúc cài DevStack; bật lại sau nếu cần |

Nếu giảng viên bắt buộc Ubuntu 22.04, dùng đúng ISO 22.04 và chốt một nhánh DevStack tương thích với mentor trước khi cài. Tài liệu DevStack hiện tại kiểm thử tốt nhất trên Ubuntu 24.04.

Trong VMware Fusion, bật tùy chọn virtualize CPU virtualization/EPT nếu phiên bản Fusion hiển thị tùy chọn này. DevStack sẽ khởi chạy guest VM bên trong OpenStack; nếu nested virtualization bị tắt, bước tạo VM có thể thất bại dù DevStack đã cài xong.

## 3. Chọn network

Ưu tiên **Bridged Networking** để Ubuntu VM nhận một IP trong cùng LAN với máy phát triển. Sau khi Ubuntu khởi động:

```bash
ip -br addr
ip route
hostname -I
```

Ghi lại:

- `DEVSTACK_VM_IP`: IP của Ubuntu VM.
- `LAN_GATEWAY`: default gateway.
- `PUBLIC_INTERFACE`: interface có IP LAN, ví dụ `ens160` hoặc `ens33`.
- `LAN_CIDR`: subnet LAN, ví dụ `192.168.1.0/24`.

Từ máy phát triển kiểm tra:

```bash
ping -c 3 DEVSTACK_VM_IP
curl -i http://DEVSTACK_VM_IP/identity/v3
ssh <ubuntu-user>@DEVSTACK_VM_IP
```

Không tự điền `192.168.1.0/24`, `ens160` hoặc gateway mẫu nếu mạng thực tế khác. Nếu Wi-Fi không cho bridged VM hoạt động, dùng NAT để cài đặt trước; khi đó cần port forwarding và việc cấp floating IP cho VM demo sẽ phức tạp hơn.

## 4. Chuẩn bị Ubuntu

Đăng nhập Ubuntu VM và chạy:

```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y git curl ca-certificates wget python3-venv
```

Kiểm tra host:

```bash
git clone https://github.com/Minhwritecode/cloud-portal.git
cd cloud-portal
chmod +x scripts/*.sh
./scripts/verify-host.sh
```

Nếu repository chưa được push hoặc URL thay đổi, copy repository vào VM bằng Git hoặc một phương thức truyền file an toàn.

## 5. Tạo user chạy DevStack

DevStack không chạy bằng root. Nếu user `stack` chưa tồn tại:

```bash
if ! id stack >/dev/null 2>&1; then
  sudo useradd -s /bin/bash -d /opt/stack -m stack
fi
echo 'stack ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/stack
sudo chmod 440 /etc/sudoers.d/stack
sudo chmod +x /opt/stack
```

Chuyển sang user `stack`:

```bash
sudo -iu stack
```

## 6. Clone DevStack ổn định

Dùng nhánh release thay vì `master` để dễ tái lập. Tại thời điểm cập nhật tài liệu, dùng `stable/2026.1`:

```bash
cd /opt/stack
git clone -b stable/2026.1 https://opendev.org/openstack/devstack
cd /opt/stack/devstack
```

Nếu nhánh này không còn phù hợp với Ubuntu/khóa học, kiểm tra release được mentor yêu cầu rồi đổi cả OS và branch thành một cặp đã chốt. Không trộn Ubuntu 22.04 với một branch chưa được nhóm kiểm thử.

## 7. Tạo local.conf riêng trên Ubuntu VM

Không chạy file example trực tiếp vì nó có placeholder. Copy và sửa:

```bash
cp /path/to/cloud-portal/infra/devstack/local.conf.example /opt/stack/devstack/local.conf
chmod 600 /opt/stack/devstack/local.conf
nano /opt/stack/devstack/local.conf
```

Bắt buộc thay:

- `HOST_IP` bằng `DEVSTACK_VM_IP`.
- Bốn password bằng password lab alphanumeric.

Chỉ bật cấu hình `PUBLIC_INTERFACE`, `FLOATING_RANGE`, `PUBLIC_NETWORK_GATEWAY` và `Q_FLOATING_ALLOCATION_POOL` sau khi đã xác nhận subnet thật. Một cấu hình sai ở phần public network có thể làm mất kết nối hoặc khiến floating IP không hoạt động.

## 8. Cài DevStack

```bash
cd /opt/stack/devstack
./stack.sh 2>&1 | tee /tmp/devstack-install.log
```

Quá trình thường mất nhiều phút và cần Internet. Nếu thất bại:

```bash
tail -n 200 /tmp/devstack-install.log
tail -n 200 /opt/stack/logs/stack.sh.log
```

Không xóa hoặc chạy lại ngẫu nhiên trước khi lưu log lỗi. Sau khi cài thành công, kiểm tra Horizon tại:

```text
http://DEVSTACK_VM_IP/dashboard
```

## 9. Kiểm tra OpenStack CLI

Trong Ubuntu VM:

```bash
source /opt/stack/devstack/openrc admin admin
openstack token issue
openstack service list
openstack image list
openstack flavor list
openstack network list
```

Chạy script kiểm tra của repository:

```bash
cd /path/to/cloud-portal
./scripts/verify-devstack.sh
```

## 10. Chuẩn bị image, flavor và security group

Tạo hai flavor nhất quán với tài liệu đồ án:

```bash
openstack flavor create --vcpus 1 --ram 1024 --disk 10 small
openstack flavor create --vcpus 2 --ram 2048 --disk 20 medium
```

Tải Ubuntu cloud image trên Ubuntu VM và upload vào Glance:

```bash
mkdir -p /opt/stack/images
cd /opt/stack/images
wget -O ubuntu-24.04-server-cloudimg-amd64.img \
  https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

openstack image create ubuntu-24.04 \
  --file ubuntu-24.04-server-cloudimg-amd64.img \
  --disk-format qcow2 \
  --container-format bare \
  --public
```

Tạo key pair và mở security group cơ bản:

```bash
openstack keypair create --public-key ~/.ssh/id_ed25519.pub portal-key
openstack security group create portal-ssh
openstack security group rule create --protocol tcp --dst-port 22 portal-ssh
openstack security group rule create --protocol icmp portal-ssh
```

Nếu máy chưa có public key, tạo bằng `ssh-keygen -t ed25519` trước. Không upload private key lên Git.

## 11. Tạo VM nghiệm thu đầu tiên

Sau khi có network và image:

```bash
openstack server create demo-vm \
  --image ubuntu-24.04 \
  --flavor small \
  --network private \
  --key-name portal-key \
  --security-group portal-ssh

openstack server show demo-vm
openstack console log show demo-vm | tail -n 50
```

VM phải chuyển từ `BUILD` sang `ACTIVE`. Nếu có floating IP pool, gán floating IP rồi thử SSH. Nếu chưa có floating IP, trước mắt nghiệm thu bằng `server show`, console log và Horizon.

## 12. Tạo clouds.yaml cho máy chạy portal

Copy template:

```bash
mkdir -p ~/.config/openstack
cp infra/openstack/clouds.yaml.example ~/.config/openstack/clouds.yaml
chmod 600 ~/.config/openstack/clouds.yaml
```

Sửa `CHANGE_ME_VM_IP`, demo password và admin password. Trên macOS, đặt rõ đường dẫn trong `.env` bằng `OS_CLIENT_CONFIG_FILE` để không phụ thuộc vào vị trí mặc định của SDK:

```dotenv
OPENSTACK_MODE=real
OPENSTACK_CLOUD=portal
OS_CLIENT_CONFIG_FILE=/Users/<user>/.config/openstack/clouds.yaml
```

Kiểm tra từ máy chạy portal:

```bash
source .venv/bin/activate
python -m pip install -r requirements.txt
export OS_CLIENT_CONFIG_FILE="$HOME/.config/openstack/clouds.yaml"
openstack --os-cloud portal token issue
```

Chỉ khi lệnh này thành công mới chuyển sang phase code OpenStack wrapper.

## 13. Snapshot và bàn giao nhóm

Tạo snapshot VMware ở các mốc:

1. Ubuntu sạch, đã cập nhật.
2. DevStack cài thành công, `openstack token issue` chạy được.
3. Tạo được `demo-vm` và kiểm tra network.

Ghi lại IP VM, branch DevStack, cấu hình vCPU/RAM/disk, tên image/flavor/network và người giữ password trong password manager. Không ghi password thật vào issue, README hoặc commit.
