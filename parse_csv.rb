module ParseCsv
    ARRAY_HEADERS = ["email", "phone"]

    #=============================================================================================
    # Hash for mapping fields from PascalCase to snake_case
    #=============================================================================================
    def self.map_hash(row)
       row.map.with_index{|header, index| [index, header]}.to_h
    end


    #=============================================================================================
    #  Parses attributes of a row, and creates a person from the Person Class
    #=============================================================================================
    def self.create_person(mapping_hash, person_attributes)
        first_name = nil
        last_name = nil
        phone = []
        email = []
        zip = nil
        person_attributes.each_with_index do | p, index|
            key = mapping_hash[index].tr("0-9", "").underscore
            #Checks to see if the fields can have multiple values assigned to them or not
            if ARRAY_HEADERS.include? key
                eval("#{key} << '#{p}'") unless p.nil?
            else
               eval("#{key} = '#{p}'") unless p.nil?
            end
        end
        Person.new(first_name: first_name, last_name: last_name, phone: phone, email: email, zip: zip)
    end

    #=============================================================================================
    #  Parses the rows from a single CSV File by name
    #=============================================================================================
    def self.parse_csv_file(csv_file, create = false)
        people = []
        check_header = 0
        mapping_hash = nil
        CSV.foreach(csv_file) do |row|
            if check_header == 0
                mapping_hash = self.map_hash(row)
                check_header = 1
            else
                people << self.create_person(mapping_hash, row)
            end
        end
        self.assign_ids(people)
        self.create_csv_file(csv_file, people) unless !create
        people unless create
    end

    #=============================================================================================
    # Assigns unique IDs for email, phone, and also the combination of email or phone
    #=============================================================================================
    def self.assign_ids(people)
        batcher = MsgBatcher.new 100, 3000 do |batch_people|
            batch_people.each do |person|
                person.identify_by_field(people, "email")
                person.identify_by_field(people, "phone")
            end
            now = Time.now
            timestamp = "#{now.min}:#{now.sec}"
            puts "PROCESSED: [#{timestamp}] size: #{batch_people.size}"
        end
        people.each do | p|
            batcher.push p
        end
        batcher.kill

        # Once the email_ids and phone_ids haven been populated, we can use these fields
        # to check by email and phone
        second_batcher = MsgBatcher.new 100, 3000 do |batch_people|
            batch_people.each do |person|
                person.check_multiple_fields(person, people)
            end
            now = Time.now
            timestamp = "#{now.min}:#{now.sec}"
            puts "PROCESSED: [#{timestamp}] size: #{batch_people.size}"
        end
        people.each do | p|
            second_batcher.push p
        end
        second_batcher.kill
    end

    #=============================================================================================
    # Create CSV File with new data
    #=============================================================================================
    def self.create_csv_file(csv_file, people)
        CSV.open("#{csv_file.split(".").first}_with_unique_ids.csv", "wb") do |csv|
            csv << self.add_headers(csv_file)
            people.each do |person|
                csv << self.create_row(csv_file, person)
            end
        end
    end

    #=============================================================================================
    # Headers to add to CSV file depending on the fomat of the inital input csv file it was read
    # from
    #=============================================================================================
    def self.add_headers(csv_file)
        if csv_file == "input1.csv"
            phone_headers = ["Phone"]
            email_headers = ["Email"]
         else
             phone_headers = ["Phone1", "Phone2"]
             email_headers = ["Email1", "Email2"]
         end
         ["EmailID", "PhoneID", "EmailAndPhoneID", "FirstName", "LastName"] + phone_headers + email_headers + ["Zip"]
    end

    #=============================================================================================
    # Creates the row that will be added to the new CSV file
    #=============================================================================================
    def self.create_row(csv_file, person)
        if csv_file == "input1.csv"
            email = person.email.join(",")
            phone = person.original_phone.join(",")
            [person.email_id, person.phone_id, person.email_and_phone_id, person.first_name, person.last_name, phone, email, person.zip]
        else
            phone1 = person.original_phone[0] || ""
            phone2 = person.original_phone[1] || ""
            email1 = person.email[0] || ""
            email2 = person.email[1] || ""
            [person.email_id, person.phone_id, person.email_and_phone_id, person.first_name, person.last_name, phone1, phone2, email1, email2, person.zip]
        end
    end


    #=============================================================================================
    # Return table of matching IDs from CSV file
    #=============================================================================================
    def self.return_people_from_csv(matching_type, csv_file, prompt_id)
        mapping_hash = {"EmailID": 0, "PhoneID": 1, "EmailAndPhoneID": 2 }
        column_to_match = mapping_hash[matching_type.to_sym]
        check_header = true
        header_id = csv_file.tr("^0-9", '').to_i
        headers = nil
        all_rows = []
        CSV.foreach(csv_file) do |row|
            matching_rows = []
            if check_header == true
                check_header = false
                headers = row
            else
                if row[column_to_match] == prompt_id
                    all_rows << row
                end
            end
        end

        table = Terminal::Table.new headings: headers, rows: all_rows
        puts !all_rows.empty? ?  table : "ID not found"
    end

end