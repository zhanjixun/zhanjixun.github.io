# SpringBoot配置文件优先级顺序

1. 命令行参数（--key=value）

   > java -jar app.jar --server.port=8081

2. 系统环境变量

   > 在操作系统中设置 `SERVER_PORT=8081`

3. 外部配置文件（按路径优先级）：
   - file:./config/
   - file:./
   - classpath:/config/
   - classpath:/

4. Profile 专属配置（如 application-{profile}.yml）

   > 例如：`application-prod.yml` > `application.yml`（当 `spring.profiles.active=prod` 时）

5. 默认配置文件

   > application.yml 或 application.properties

6. @PropertySource 注解指定的文件

   ```java
   @Configuration
   @PropertySource("classpath:custom.properties")
   public class AppConfig { ... }
   ```

7. SpringApplication.setDefaultProperties() 的默认值

   ```java
   SpringApplication app = new SpringApplication(App.class);
   app.setDefaultProperties(Collections.singletonMap("server.port", "8080"));
   app.run(args);
   ```

   