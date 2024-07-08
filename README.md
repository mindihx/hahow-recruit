# Hahow Recruit

[專案規格說明](backend-b2b.md)

## 使用版本

- Ruby：參考 [Gemfile](Gemfile) 裡的 `ruby`。
- Rails：參考 [Gemfile](Gemfile) 裡的 `gem "rails"`。
- Postgres：參考 [docker-compose.yml](docker-compose.yml)。

# 如何執行 server

## 本地執行

### 安裝並啟動 Postgres server

可以在本地安裝 Postgres server，或安裝 Docker 並使用 Docker Compose 啟動 Postgres server：

```
docker compose up -d
```

### 安裝並啟動 Rails server

1. 安裝對應版本的 Ruby（可使用 rvm 或其他類似工具）。
2. 複製 `.env.sample` 到 `.env` 並修改對應的 postgres 帳號及密碼。
3. 執行 `bundle install`。
4. 執行 `rails db:create` 及 `rails db:migrate` 初始化資料庫。
5. 執行 `rails s` 啟動 server 並執行 `curl http://localhost:3000/api/v1/admin/courses` 確認有成功回傳。
6. 執行 `rspec spec` 確認測試通過。

## 執行已部署的服務

API 部署在 https://hahow-recruit.onrender.com/ 上面，執行範例如下（第一個 request 會需要等服務從休眠中喚起，需要等一分鐘左右）：

課程列表

```
curl 'https://hahow-recruit.onrender.com/api/v1/admin/courses'
```

課程詳細資訊

```
curl 'https://hahow-recruit.onrender.com/api/v1/admin/courses/1'
```

建立課程

```
curl 'https://hahow-recruit.onrender.com/api/v1/admin/courses' \
--header 'Content-Type: application/json' \
--data '{
    "name": "first course",
    "teacher_name": "teacher X",
    "description": "my first course description",
    "chapters_attributes": [
        {
            "name": "chapter 1",
            "units_attributes": [
                {
                    "name": "單元ㄧ",
                    "description": "this is unit 1",
                    "content": "單元內容"
                },
                {
                    "name": "unit 2",
                    "description": "this is unit 2",
                    "content": "unit 2 content"
                }
            ]
        }
    ]
}'
```

編輯課程 (範例為修改單元一的內容、刪除單元二及新增章節二，id 需要替換成正確的才能執行)

```
curl 'https://hahow-recruit.onrender.com/api/v1/admin/courses/2' \
--request PATCH \
--header 'Content-Type: application/json' \
--data '{
    "name": "first course",
    "description": "my first course description",
    "chapters_attributes": [
        {
            "id": 2,
            "name": "chapter 1",
            "units_attributes": [
                {
                    "id": 2,
                    "name": "單元ㄧ",
                    "description": "this is unit 1",
                    "content": "new 單元內容"
                },
                {
                    "id": 3,
                    "_destroy": true
                }
            ]
        },
        {
            "name": "chapter 2",
            "units_attributes": [
                {
                    "name": "unit 1",
                    "description": "this is unit 1",
                    "content": "unit 1 content"
                }
            ]
        }
    ]
}'
```

刪除課程（id 需要替換成正確的才能執行）

```
curl 'https://hahow-recruit.onrender.com/api/v1/admin/courses/2' --request DELETE
```

# 專案及 API server 架構

執行 `rails routes` 可以列出所有 API，目前 API 路徑都放在 `/api/v1` 下面，`/admin` 表示為後台管理功能相關的 API，例如管理課程。

當 HTTP status code = 200 時表示 API 成功，如果 status code = 4xx、5xx 時表示失敗，回傳皆為 JSON format，成功時會是：

```
{
    "data": <data>,
    "meta": <meta>
}
```

失敗時會是：

```
{
    "error": {
        "message": <error message>
    }
}
```

目前管理課程相關的 API 如下，詳細的使用方式可參考 rspec 測試：

### 課程列表

`GET /api/v1/admin/courses`

列出所有課程及包含的章節、單元資訊。

- 因為是列表所以不回傳過於細節的資訊例如課程的說明、單元的說明及內容。
- 按照課程 id 降冪排序。
- 有實作分頁功能，參數 `page` 指定頁數，預設為 1，參數 `per_page` 指定一頁有幾筆，預設為 20，最大為 100。

### 課程詳細資訊

`GET /api/v1/admin/courses/:id`

列出指定 id 的課程及包含的章節、單元資訊。

### 建立課程

`POST /api/v1/admin/courses`

建立課程及包含的章節、單元

- 章節跟單元的順序會自動根據其在傳入 array 裡的順序決定並儲存。
- 課程至少須包含 1 個章節，最多 100 個章節，每個章節至少須包含 1 個單元，最多 100 個單元。

### 編輯課程

`PATCH /api/v1/admin/courses/:id`

編輯課程及包含的章節、單元。

- 需要傳入該課程全部的章節及單元，且章節跟單元的順序會自動根據其在傳入 array 裡的順序決定並儲存。如果只傳入部分的章節及單元，順序有可能會被打亂。
- 如果章節或單元沒有提供 `id` 的話就會新增，如果有提供 `_destroy: true` 的話就會刪除。

### 刪除課程

`DELETE /api/v1/admin/courses/:id`

刪除課程及包含的章節、單元。

# 使用到的第三方 Gem

### jsonapi-serializer

JSON API 的 serializer，用來產生 API 需要的 response 內容，較方便維護不會散落在 controller 裡面。

### kaminari

實作列表的分頁功能。在 [config/initializers/kaminari.rb](config/initializers/kaminari.rb) 裡面有定義預設及最大的 `per_page` 值。

### dotenv-rails

可以讀 `.env` 當作環境變數，方便本地開發。

### rubocop 相關

- rubocop-rails
- rubocop-rspec

Rails 程式碼的 linter 及 formatter，可協助保持程式碼風格一致並做基本的程式碼檢查。在 [.rubocop.yml](.rubocop.yml) 裡面有調整一些規則，例如使用雙引號。

### rspec 相關

- database_cleaner-active_record：讓每次執行測試都是使用乾淨的資料庫。在 [spec/rails_helper.rb](spec/rails_helper.rb) 裡面執行 truncation 讓資料庫 table 的 id 可以 reset，不會隨著跑測試一直累積。
- factory_bot_rails：方便在測試裡產生需要的 instance。例如在 [spec/factories/chapters.rb](spec/factories/chapters.rb) 定義必填欄位及必要的關聯，方便測試使用。
- rspec-json_expectations：方便測試 API 的 JSON response 是否符合預期。這個 gem 已經很久沒有更新，但因為之前有用過這個 gem 所以就先沿用。

# 寫註解的原則

註解主要是用來協助表達程式碼本身無法表達的意圖，主要會在下面這些情況下寫註解：

- 提供之後需要理解、修改程式碼或者使用程式碼的人需要知道或注意的事情。
  - 例如一個方法的參數細節，如果是時間的話單位是什麼、如果允許 nil 那 nil 代表什麼等等。或這個方法是否有任何執行的前提，以及它會造成的效果。
- 某段程式碼的寫法很特別，需要解釋為什麼要這樣做。
- TODO, FIXME 這類暫時標註某段程式碼可能尚未完整或存在問題待解。

如果是像是設計文件或更細節更多的內容，也會考慮放到另外的文件並加註解附上該文件的連結。另外當需要寫註解的時候也可以先想一下是否有更容易理解而不需要註解的更好寫法。

# 實作方式的選擇

## RESTful

雖然之前有用 Python 及 Node.js 寫過 GraphQL，但因為沒有用 Rails 實作過所以這次決定還是先用 RESTful。

## JSON serializer

有考慮過是否要使用 serializer 及要用哪種 serializer，自己有用過的是 Jbuilder、active_model_serializers 及這次選擇的 jsonapi-serializer。為了能夠較方便且快速的開發所以選擇了裡面自己覺得比較好用的 jsonapi-serializer，沒有花時間再 survey 其他 serializer。

## API path 有 /api/v1 prefix

雖然只是作業用的專案可能不需要考慮到 API 版本控制，不過還是在 path 上加上版本 `/v1`。而多了 `/api` 讓 server 所有的 API 有共同的前綴是為了之後有需要的話方便做 routing（例如把所有 `/xxx` 開頭的 path 都導到 API server 的 `/api`）。

## 編輯課程的 API 需要傳進全部資料

依據規格將新增、刪除、編輯章節及單元放在同一個 API 完成，而為了比較好實作順序的調整，假設傳進來的是該課程全部的資料（即如果該課程有三個章節，只修改一個章節也是要傳三個章節進來）。但實際上每次修改一個章節或單元就要傳全部的章節是很沒有效率的，因此如果沒有限制要單一 API 的話可以考慮將調整順序的 API 獨立出來，並且可以在新增章節時允許提供順序的資訊等等。

## with_detail v.s. hide_detail

因為列表只顯示部分欄位，有考慮過 serializer 控制的 flag 命名要是 with_detail 還是 hide_detail，with_detail 的好處是判斷的地方不用做否定比較好讀，但由於大部分的 API（show、create、update、destroy）都是需要全部欄位的，所以希望不傳此 flag 預設就是全部欄位，而決定使用 hide_detail。

## 將排序寫在 has_many 裡面

有考慮過要不要在 has_many 的關係裡直接預設根據 position 排序（例如 `has_many :units, -> { order(position: :asc) }`），這樣會讓有些不需要排序的情境多做排序。後來決定要加是為了避免額外的 query，如果將排序寫成 scope 然後在 serializer 裡面才排序 (例如 `chapter.units.in_order`)，就會有額外的 query，且考慮到大部分的情境都會需要有排序所以還是決定要加。

## check_chapters_and_units_num 不放入 model validation

`check_chapters_and_units_num` 只有放在 controller 檢查而不放到 model 本身的 validation，主要是為了避免測試太複雜，例如只是想測試 course 卻一定至少要開出一個 chapter 及 unit。想像中只會有少數 API 做建立或編輯課程的行為，所以較不至於會漏加而影響資料正確性。實務上如果真的要避免學生看到有空的課程或章節，也可以考慮在課程上線的 API 加檢查。

## 其他可以做但因為時間因素或判斷不在此作業範圍而未實作的部分

- API 文件，之前有用過 API Blueprint、Swagger（OpenAPI）。
- soft delete，之前有用過 discard、paper_trail，soft delete 是為了避免誤刪，但也不是所有的 model 都要加，也是要考慮該資料被誤刪後的影響程度。
- 因為一個講師可能會開多堂課程，為了方便管理可以獨立出一個講師的 table，在課程 table 只需要儲存講師 id。
- 將建立/編輯課程合成一個 API，減少 create_params 及 update_params 欄位的重複，但邏輯也會變比較複雜。
- 因為編輯課程 API 假設要傳入所有的章節及單元，所以應該增加檢查，如果不符合假設就回傳錯誤。
  - 或者允許只修改單一章節，例如自動判斷如果沒有傳入所有的章節與單元就不自動調整順序而是讓使用者指定。
- 建立或編輯課程的回傳錯誤沒有特別指出是哪一個章節或哪一個單元的問題，看到錯誤訊息會比較難定位錯誤。
- 不特別去除前後空白或檢查特定字元，因為覺得名稱、說明及內容都有可能會需要前後空白且無法訂出只能用哪些字元。
- 不檢查說明及內容的長度，因為比較難定義出一個合理的最大值，且 admin API 理論上會需要登入且特定使用者才能使用，通常 API 也都會擋傳入 payload 的大小上限，所以這邊先不檢查。
- 有考慮過是否要檢查名稱不能重複，但後來自己判斷應該是不需要（例如應該要允許同時有兩堂課都叫「程式設計導論」）。
- 本來有使用 faker gem 來產生測試的欄位資料，但後來覺得目前的使用情境其實不需要就先移除了。

# 遇到的問題與解決方法

## 環境設定

- 安裝 Ruby 3.3.3 遇到 openssl 重複定義的問題，在安裝時指定 openssl 路徑 (--with-openssl-dir) 就可解決。

## 部署 server

### 選擇要用哪個服務部署

因為 Heroku 沒有免費的服務了所以稍微 survey 了其他可用的，本來試用了 Koyeb 發現它的 db 只能用 50 小時，後來才改用 Render。

### 修正了以下 docker build 問題

- Ruby 3 的一些 dependency 問題但沒有細看，在 Gemfile 裡加上 `gem "net-pop", github: "ruby/net-pop"` 可解決。
- 沒有安裝 libpg-dev 造成的安裝錯誤，在 apt-get install 加上 libpg-dev。
- 因為把 active storage 拿掉所以就不能做 `rails assets:precompile` 且 [config/environments/production.rb](config/environments/production.rb) 也要註解掉 `config.active_storage.service = :local`。
- 因為把 action cable 拿掉所以需要移除相關檔案 `app/channels/application_cable/channel.rb`、`app/channels/application_cable/connection.rb`。

### 修正了以下執行問題

- 沒有設定 RAILS_MASTER_KEY，之前沒有使用過這個機制，所以看了一下要從哪裡取得 master key。
- POST request 沒有給 CSRF token 而不能執行，將 `ApplicationController` 改成繼承 `ActionController::API` 而不是 `ActionController::Base`。也可以用其他方法例如加上 `skip_before_action :verify_authenticity_token`。

## request as json

一開始寫測試的時候忘記 post 及 patch 要加上 `as: :json`，所以應該都是用 form data 在傳資料。在寫 update 測試的時候遇到很奇怪的行為，例如多個 unit 第一個沒有傳 id 第二個有傳，但收到的 params 卻變成第一個有 id 第二個沒有，花了一點時間 debug 之後才想到原因。
