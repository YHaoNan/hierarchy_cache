local function close_redis(red)
  local pool_max_idle_time = 10000
  local pool_size = 100
  local ok, err = red:set_keepalive(pool_max_idle_time, pool_size)

  if not ok then
    ngx.log(ngx.ERR, "error to put to redis conn")
  end
end

local function read_redis(red, ip, port, key)
  local ok, err = red:connect(ip, port)
  if not ok then
    ngx.log(ngx.ERR, "error to connect to redis: ", err)
  end

  local resp, err = red:get(key)
  if not resp then
    ngx.log(ngx.ERR, "error when get value from redis: ", err)
  end

  if resp == ngx.null then
    resp = nil
    ngx.log(ngx.ERR, "the data from redis is nil, key => ", key)
  end

  close_redis(red)
  return resp
end

local function request(path, params)
  local resp = ngx.location.capture(path, {
    method = ngx.HTTP_GET,
    args = params,
  })

  if not resp then
    ngx.log(ngx.ERR, "request faild: ", path, ", args: ", args)
    ngx.exit(404)
  end
  return resp.body
end


return {
  request = request,
  read_redis = read_redis,
  close_redis = close_redis,
}
