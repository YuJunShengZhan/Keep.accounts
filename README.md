# 簡單記帳 — Supabase + GitHub Pages 版

這版已經完全移除 Firebase，改用 **Supabase**。

功能：
- Email / 密碼註冊
- Email / 密碼登入
- 每個帳號各自獨立記帳資料
- 收入 / 支出 / 結餘
- 自訂收入統計期間
- GitHub Pages 可部署
- iPhone Safari 加入主畫面
- PWA standalone 模式
- App Logo

---

## 第 1 步：建立 Supabase 專案

到 Supabase 建立免費 Project。

建立完成後，到：

**Project Settings → API**

找到：

- Project URL
- Publishable key  
  舊介面可能顯示 `anon public`

打開 `supabase-config.js`：

```js
window.SUPABASE_CONFIG = {
  url: "你的 Project URL",
  key: "你的 Publishable key"
};
```

> 不要使用 service_role key。  
> 網頁前端只能放 Publishable / anon key。

---

## 第 2 步：建立資料表與安全權限

Supabase Dashboard：

**SQL Editor → New query**

打開本專案的：

`supabase-setup.sql`

把裡面內容全部複製到 SQL Editor，按 **Run**。

它會建立：

- `entries`
- `user_settings`

並啟用 Row Level Security（RLS）。

每個登入帳號只能讀、寫、修改、刪除自己的資料。

---

## 第 3 步：設定 Email 登入

Supabase Dashboard：

**Authentication → Providers → Email**

Email 登入通常預設已啟用。

如果保留「Confirm email」：

1. 新使用者註冊
2. 去信箱點驗證信
3. 再回網站登入

如果只是你自己測試，也可以暫時關掉 Confirm email，
註冊後就會直接登入。

---

## 第 4 步：設定 GitHub Pages 網址

先部署 GitHub Pages，再得到網址，例如：

`https://你的帳號.github.io/simple-accounting/`

Supabase Dashboard：

**Authentication → URL Configuration**

設定：

### Site URL
填入你的 GitHub Pages 網址。

例如：

`https://你的帳號.github.io/simple-accounting/`

### Redirect URLs
也加入相同網址：

`https://你的帳號.github.io/simple-accounting/**`

Email 驗證完成後才能正確回到你的網站。

---

## 第 5 步：部署 GitHub Pages

1. GitHub 新增 Repository，例如 `simple-accounting`
2. 把 ZIP 解壓縮後的所有檔案，上傳到 Repository 根目錄
3. Repository → **Settings**
4. 左邊選 **Pages**
5. Source 選 **Deploy from a branch**
6. Branch 選 **main**
7. Folder 選 **/(root)**
8. Save

等待 GitHub Pages 完成部署。

---

## 第 6 步：iPhone 加入主畫面

請用 iPhone **Safari**：

1. 開啟你的 GitHub Pages 網址
2. 點 Safari 的「分享」
3. 選 **加入主畫面**
4. 按 **新增**

主畫面會使用專案內的 App Logo。

從主畫面開啟後，會以接近 App 的 standalone 模式顯示。

---

## 檔案說明

- `index.html` — 記帳主程式
- `supabase-config.js` — 填入 Supabase Project URL / key
- `supabase-setup.sql` — 建立資料表 + RLS 安全規則
- `manifest.webmanifest` — PWA 設定
- `sw.js` — Service Worker
- `icon-180.png` — iPhone icon
- `icon-192.png` — PWA icon
- `icon-512.png` — 高解析 PWA icon

---

## 資料安全

前端可以看見 Publishable / anon key 是正常的。

真正保護資料的是 `supabase-setup.sql` 中設定的 RLS。

資料表每一筆都有：

`user_id`

政策會檢查：

`auth.uid() = user_id`

所以登入 A 帳號不能讀取 B 帳號的記帳資料。
