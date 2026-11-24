# dojo-pull

Kéo challenge files từ workspace pwn.college (`/challenge`) về máy qua SSH, trong một kết nối (tar stream).

## Cài đặt

```bash
curl -fsSL https://raw.githubusercontent.com/chihuyenichi/dojo-pull-tool/main/install.sh | bash
dojo-pull init
```

- Cài bằng **user thường**, không dùng `sudo`. Tool nằm ở `~/.local/bin/dojo-pull`; nếu lệnh không tìm thấy, thêm vào PATH:
  `grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc`
- Ghim phiên bản: `DOJO_PULL_REF=v0.1.2 bash install.sh`. Gỡ: `bash install.sh --uninstall`.
- Cài từ bản clone: `./install.sh`. Cài cho mọi user: `sudo PREFIX=/usr/local ./install.sh`.
- Nên xem script trước khi chạy: `curl -fsSL <url> | less`.

## Sử dụng

```bash
dojo-pull init                       # tạo config, kiểm tra SSH key
dojo-pull doctor                     # kiểm tra tool / key / quyền / kết nối
dojo-pull update                     # cập nhật (alias: upgrade) [ref]

dojo-pull -d ./challenge             # kéo toàn bộ /challenge
dojo-pull -d ./challenge -m pwn.baby # theo prefix
dojo-pull 'babysuid_level[0-9]+' -n  # regex ERE, -n = chỉ liệt kê
```

| Cờ | Ý nghĩa |
|---|---|
| `-d DIR` | thư mục đích |
| `-m PREFIX` | chỉ kéo tên bắt đầu bằng prefix |
| `-n` | dry-run |
| `-v` | verbose |
| `--rsync` | dùng rsync thay cho tar |
| `--config FILE` | dùng file config khác |
| `-V` | phiên bản |

Pattern là ERE của `grep -E` (dùng `[0-9]`, không dùng `\d`). Chỉ challenge đang bật trong workspace mới có trong `/challenge`.

Mã thoát: `2` SSH/key lỗi, `3` không có file khớp, `4` thư mục đích không ghi được.

## Cấu hình

`~/.config/dojo-pull/config` (dạng `KEY="value"`, không được `source`):

| Key | Mặc định |
|---|---|
| `SSH_HOST` | `dojo.pwn.college` |
| `DOJO_USER` | `hacker` |
| `SSH_PORT` | `22` |
| `KEY_PATH` | `~/.ssh/dojo_pwncollege` |
| `REMOTE_DIR` | `/challenge` |
| `DEST_DIR` | `./challenge` |
| `METHOD` | `tar` (hoặc `rsync`) |
| `OVERWRITE` | `skip` (hoặc `overwrite`, `backup`) |
| `CHMOD_EXEC` | `1` |

Thứ tự ưu tiên: cờ dòng lệnh > biến môi trường `DOJO_<KEY>` (vd `DOJO_KEY_PATH`) > file config > mặc định.

## SSH key

`dojo-pull init` kiểm tra key và in lệnh còn thiếu. Thủ công:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/dojo_pwncollege -N ""
cat ~/.ssh/dojo_pwncollege.pub    # dán vào pwn.college -> Settings -> SSH Keys
```

## Quyền và user

- Chạy bằng user thường. Thư mục đích phải thuộc về bạn; nếu không, tool báo thư mục nào đang chặn và cách sửa.
- Chạy bằng root: tool cảnh báo. Chạy qua `sudo`: file kéo về được trả lại cho `$SUDO_USER`.
- WSL: key và config nằm trong home của WSL (`/home/<user>`), không dùng chung với Windows.

## Cách khác: `pull.sh` và Docker

`pull.sh` + `pull.conf` là bản script cũ đọc cấu hình từ `pull.conf` cạnh nó; `run-docker.sh` chạy `pull.sh` trong container (mount key `~/.ssh/id_ed25519`, output ra `./outputs`).

```bash
./pull.sh -n
./run-docker.sh 'babysuid'
```

## Cấu trúc

```
dojo-pull           # CLI chính
install.sh          # cài vào ~/.local/bin (curl | bash hoặc từ clone)
pull.sh, pull.conf  # bản script độc lập
Dockerfile, docker-compose.yml, run-docker.sh, .dockerignore   # đóng gói Docker cho pull.sh
```
