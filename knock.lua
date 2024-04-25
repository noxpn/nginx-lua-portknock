-- init vars
local fw_open_script = '/etc/nginx/lua/add_nft_rule.sh'
local fw_close_script = '/etc/nginx/lua/del_nft_rule.sh'
local valid_host = "element.noxp.online"
local max_uri_len = 100
-- EXAMPLE: /endpoint/user/password/action
local timeout = 15
local exit_status = 402
local valid_uri_parts = 4
local password = 's0MeGreatPa$$w0Rd'
local actions = {}
actions[1] = 'health'
actions[2] = 'knock'
actions[3] = 'action3'
actions[4] = 'action4'

local uri_parts = {}
-- 1 endpoint, 2 user, 3 pwd, 4 action 
--
local time = os.date("%Y/%m/%d %H:%M:%S")
local uri = ngx.var.request_uri
local ip = ngx.var.remote_addr
local host = ngx.var.http_host
local f_id = ngx.md5(ip..time) 
local id = string.sub(f_id, string.len(f_id)/4*2, string.len(f_id)/4*3)

ngx.header["Content-type"] = "text/plain"

-- request host check
if valid_host ~= host then
  ngx.log(ngx.ERR, 'ERR: host invalid: ', host)
  ngx.exit(exit_status)
end

-- URI Len check
local uri_len = string.len(uri)
if string.len(uri) > max_uri_len then
  ngx.log(ngx.ERR, 'ERR: too long uri: ', uri_len)
  ngx.exit(exit_status)
end

-- URI parts check
for i in string.gmatch(uri, "[^/]+") do
   table.insert(uri_parts,i)
end

if table.maxn(uri_parts) ~= valid_uri_parts then 
   ngx.log(ngx.ERR, 'ERR: parts in uri: ', table.maxn(uri_parts))
   ngx.exit(exit_status)
end

-- PWD check
if password == uri_parts[3] then 
else
  ngx.log(ngx.ERR, 'ERR: Pwd invalid: ',  uri_parts[3])
  ngx.exit(exit_status)
end

-- Action check 
local found = false
for i,v in pairs(actions) do
  if v == uri_parts[4] then
    found = true
  end
  if found then break end
end
if found == false then
  ngx.log(ngx.ERR, 'ERR: invalid action:', uri_parts[3])
  ngx.exit(exit_status)
end


local function chk_file(c)
  local f = io.open(c, "r") -- Open our file read-only.
  if f ~= nil then
    io.close(f)
    return true
  end
  return false
end


-- check our script available
if not chk_file(fw_open_script) then
  ngx.log(ngx.ERR, 'ERR: invalid script :', fw_open_script)
  ngx.exit(exit_status)
end

if not chk_file(fw_close_script) then
  ngx.log(ngx.ERR, 'ERR: invalid script :', fw_close_script)
  ngx.exit(exit_status)
end


local function exec_script (premature, cmd) 
    if premature then
      return
    end
    local h= io.popen(cmd)
    result = h:read("*a")
    h:close()
    return result
end

-- actions exec

if uri_parts[4] == 'health' then
  ngx.say('ok')
end

-- construct cmdline and id with username
id = id..'#'..uri_parts[2]
local cmd_line = string.format('%s %s %s', fw_open_script, ip, id)


if uri_parts[4] == 'knock' then
  local res = exec_script(false, cmd_line)
    ngx.say('#',res)
    ngx.say('timeout: ',timeout)
    local ok, err = ngx.timer.at(timeout, exec_script, string.format('%s %s %s %s', fw_close_script, ip, id, string.match(res, '%d+')))
    if not ok then
      ngx.log(ngx.ERR, "failed to create the timer: ", err)
      return
    else
      ngx.log(ngx.ERR, "timer ok")
    end
end


