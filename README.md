## openresty_demo

这两天学习`openresty`, 利用学习时间, 写了一个动态代理的功能, 使用以下几个模块.

* [redis](https://gist.githubusercontent.com/moonbingbing/9915c66346e8fddcefb5/raw/8921bf06c019c21ca694e82a7a0074ce58c49e3d/redis.lua)
* [lrucache](https://github.com/openresty/lua-resty-lrucache)
* [http](https://github.com/pintsized/lua-resty-http)


原理模拟了SAP的SMP: 为每个代理应用起一个唯一ID名称, 用此名称最为redis的key, 使用hash保存需要代理的信息, 如代理服务器IP或者是域名. 

请求URI规则为: http://代理服务器IP或域名:端口号/唯一ID名称/应用URI

举例: 

* 代理服务器: 10.2.0.100
* 应用服务器: 10.1.1.101:8081/App/search 
* 唯一ID假设取名为: cn.com.test.search

则代理请求应该为: http://10.2.0.100/cn.com.test.search/search
redis中应该保存: key: cn.com.test.search filed: connect value: http://10.1.101:8081/App


客户端发起请求, 代理服务器根据请求获取应用ID, 根据ID从redis中获取目标服务器地址, 将请求转发目标服务器, 获取结果后返回给客户端.
