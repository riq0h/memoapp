## Usage

```
git clone https://github.com/riq0h/memoapp.git
cd memoapp
bundle install
createdb memo_app
createuser -P -s -e your_username
psql -U your_username -d memo_app -f memos.sql
ruby app.rb
```
