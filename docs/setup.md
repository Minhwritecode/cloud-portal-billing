# Hướng dẫn cài đặt

## 1. Máy chạy Web Portal

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
python run.py
```

## 2. Kết nối OpenStack thật

Đặt file credential tại `~/.config/openstack/clouds.yaml` trên máy chạy portal.
Sau đó sửa `.env`:

```dotenv
OPENSTACK_MODE=real
OPENSTACK_CLOUD=portal
```

Không đưa file credential vào repository.

## 3. Kiểm tra

```bash
pytest -q
curl http://127.0.0.1:8000/health
```
