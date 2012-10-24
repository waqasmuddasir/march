class AddIpsAndIpcontentsTable < ActiveRecord::Migration
  def self.up
    create_table :ips do |t|
      t.column :ipnumber, :"integer unsigned"
      t.string :ip
      t.column :ipcontent_id, :"integer unsigned"
    end
    
    create_table :ipcontents do |t|
      t.column :content_file_prefix, :"integer unsigned"
      t.string :type
    end

    add_index :ips, :ipnumber
    add_index :ips, :ipcontent_id
    add_index :ipcontents, :content_file_prefix
    messages=[%{<p>
          Ultra Vie1 is a new service for premium experiences, offering a hand-picked selection of fine-dining, shopping events, private access and professional services to the discerning Londoner.
          If you’d like to be the first to know when Ultra Vie is available, please <a href="Javascript:" onclick="showSignup();" >sign up</a>.
        </p>},%{<p>
          Ultra Vie2 is a new service for premium experiences, offering a hand-picked selection of fine-dining, shopping events, private access and professional services to the discerning Londoner.
          If you’d like to be the first to know when Ultra Vie is available, please <a href="Javascript:" onclick="showSignup();" >sign up</a>.
        </p>},%{<p>
          Ultra Vie3 is a new service for premium experiences, offering a hand-picked selection of fine-dining, shopping events, private access and professional services to the discerning Londoner.
          If you’d like to be the first to know when Ultra Vie is available, please <a href="Javascript:" onclick="showSignup();" >sign up</a>.
        </p>},%{<p>
          Ultra Vie4 is a new service for premium experiences, offering a hand-picked selection of fine-dining, shopping events, private access and professional services to the discerning Londoner.
          If you’d like to be the first to know when Ultra Vie is available, please <a href="Javascript:" onclick="showSignup();" >sign up</a>.
        </p>},%{<p>
          Ultra Vie5 is a new service for premium experiences, offering a hand-picked selection of fine-dining, shopping events, private access and professional services to the discerning Londoner.
          If you’d like to be the first to know when Ultra Vie is available, please <a href="Javascript:" onclick="showSignup();" >sign up</a>.
        </p>},%{<p>
          Ultra Vie6 is a new service for premium experiences, offering a hand-picked selection of fine-dining, shopping events, private access and professional services to the discerning Londoner.
          If you’d like to be the first to know when Ultra Vie is available, please <a href="Javascript:" onclick="showSignup();" >sign up</a>.
        </p>}]
    messages.each{|message|
      AboutUsMessage.create({:message=>"#{message}"})
    }
  end

  def self.down
    AboutUsMessage.all.each{|message|
      message.destroy
    }
    drop_table :ips    
    drop_table :ipcontents
  end
end
