local common = require('common')
local cjson = require('cjson')
local redis = require('resty.redis')
local item_cache = ngx.shared.item_cache

local redisCli = redis:new()
redisCli:set_timeouts(1000, 1000, 1000)

function read_data(key, expire, path, params)
  -- 查询本地缓存
  local resp = item_cache:get(key)
  if not resp then
    ngx.log(ngx.ERR, "local cache not hit, key => ", key)
    -- 查询redis
    resp = common.read_redis(redisCli, "172.21.8.70", 6379, key)
    if not resp then
      -- redis查询失败，走http查询到tomcat
      resp = common.request(path, params)
    end
  end
  item_cache:set(key, resp, expire)
  return resp
end


local id = ngx.var[1]

-- 商品和库存信息
local HALF_AN_HOUR = 1800
local A_MINUTE = 60

local item = cjson.decode(read_data('item:'..id, HALF_AN_HOUR, '/item/'..id, nil))
local stock = cjson.decode(read_data('stock:'..id, A_MINUTE, '/item/stock/'..id, nil))
item.stock = stock.stock;
item.sold = stock.sold;

ngx.say(cjson.encode(item))
