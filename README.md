## Installation
1. Put the following line into the Gemfile of your project
```
   gem 'huaweicloud-sms'
```

2. Install the gems in Gemfile
```
   $ bundle install
```

## Usage
1. Initialize the SMS instance

```
   instance = HuaweiCloudSms.new(app_key, app_secret, url)
```

2. Send SMS
```
   instance.send(sender, receiver, template_id, template_params, signature)
```
