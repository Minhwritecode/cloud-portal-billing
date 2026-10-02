# Cloud Portal

Đồ án xây dựng cổng dịch vụ Cloud tự phục vụ trên OpenStack.

## Kiến trúc

- Ubuntu VM trên MacBook: DevStack/OpenStack.
- Máy phát triển: Web Portal, database và billing worker.
- `openstack_client/`: lớp kết nối với OpenStack SDK.
- `billing/`: logic tính cước và background worker.
- `tests/`: unit test, integration test và end-to-end test.

## Khởi động nhanh

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
python run.py
```

Mở `http://127.0.0.1:8000/health` để kiểm tra ứng dụng.

## Chế độ chạy

- `OPENSTACK_MODE=mock`: phát triển giao diện và billing khi OpenStack chưa bật.
- `OPENSTACK_MODE=real`: gọi OpenStack thật qua `clouds.yaml`.

Không commit `.env`, `clouds.yaml`, password, token hoặc private key lên Git.

## Quy trình Git

```bash
git checkout -b feature/ten-tinh-nang
git add .
git commit -m "feat: mo ta thay doi"
git push -u origin feature/ten-tinh-nang
```

Mọi thay đổi nên đi qua Pull Request trước khi merge vào `main`.
