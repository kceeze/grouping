# Instructions (Ruby)
 1. Please install the following GEMS:
    - msg-batcher: https://rubygems.org/search?query=msg-batcher
    - byebug (optional): https://rubygems.org/gems/byebug
    - csv: https://rubygems.org/gems/csv
    - activesupport: https://rubygems.org/gems/activesupport/versions/7.1.3.2?locale=en

2. In ruby run the main.rb file: "ruby main.rb"

3. Once the file finishes running, you should see 3 new files created from the default CSV Files in this directory. The new files will have 3 new fields added to them:
    - EmailID - used to uniquely identify rows with the exact same emails
    - PhoneID - used to uniquely identify rows with the exact same phone numbers
    - EmailAndPhoneID - used to uniquely identify rows with exact same email or phone number
