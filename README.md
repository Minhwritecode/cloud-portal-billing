# Cloud Portal

Đồ án xây dựng cổng dịch vụ Cloud tự phục vụ trên OpenStack. Repository hiện được chuẩn bị theo hướng **setup hạ tầng trước, viết tính năng sau**.

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
