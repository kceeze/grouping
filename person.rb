class Person
    attr_accessor :first_name, :last_name, :email, :phone, :zip, :email_id, :phone_id, :email_and_phone_id, :original_phone

    def initialize(first_name: nil, last_name: nil, email: nil, phone: nil, zip: nil,  email_id: nil, phone_id: nil, email_and_phone_id: nil)
        @first_name = first_name
        @last_name = last_name
        @email = email
        @original_phone = phone
        @phone = format_phone_numbers(phone)
        @zip = zip
        @email_id = email_id
        @phone_id = phone_id
        @email_and_phone_id = email_and_phone_id
    end

    #=============================================================================================
    # Populates the field id given with a unique identifier based on if a match if found.
    # If no match is found we give it a new ID
    #=============================================================================================
    def identify_by_field(people, field_name)
        people_with_unique_identifier = people.select { |a| a.send("#{field_name}_id") }
        if people_with_unique_identifier.empty?
          self.send("#{field_name}_id=", SecureRandom.uuid)
        else
          match = people_with_unique_identifier.find { |a| self.send(field_name).intersection(a.send(field_name)).any? }
          self.send("#{field_name}_id=", match.nil? ? SecureRandom.uuid : match.send("#{field_name}_id"))
        end
    end


    #=============================================================================================
    # Populates the field id given with a unique identifier based on if a match if found.
    # In this case were using a match on both email or phone ID
    #=============================================================================================
    def check_multiple_fields(person, people)
        people_with_unique_identifier = people.select{|a| a.email_and_phone_id }
        if people_with_unique_identifier.empty?
            self.email_and_phone_id = SecureRandom.uuid
        else
            match = people_with_unique_identifier.find{|a| a.email_id == self.email_id || a.phone_id == self.phone_id}
            self.email_and_phone_id = match.nil? ? SecureRandom.uuid : match.email_and_phone_id
        end
    end


    #=============================================================================================
    # We need to format the different numbers into a unified way, such that we can find matches
    # where a number may appear formatted differntly
    #=============================================================================================
    def format_phone_numbers(phone)
        numbers = []
        phone.each do | number|
            digits = number.gsub(/\D/, '')
            digits = digits[1..] if digits.length == 11 && digits.start_with?('1')
            numbers << "#{digits[0..9]}"
        end
        numbers
    end
end