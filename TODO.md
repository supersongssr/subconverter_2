- [x] 编译
    - 在 debian上,编译 debian需要的版本. 

- [] bug: 在 转换 ss 订阅到 clash 的 yaml格式的时候
    - 发现 节点名字没有加 ""
    - 输出格式是这样的: {name: 账号test_user_042@example.com, server: google.com, port: 443, type: ss, cipher: aes-128-gcm, password: 6601fb90e9b3}
    - 正确的应该是 {name: "账号test_user_042@example.com", server: google.com, port: 443, type: ss, cipher: aes-128-gcm, password: 6601fb90e9b3}