class Administration::EmailTemplate < ActiveRecord::Base
 
  def self.list
    all
  end

  def self.parse_subject(subject_tags,template_type_id)
  email_template=Administration::EmailTemplate.find_by_email_template_types_id(template_type_id)
  subject = ""
  if email_template
    subject = email_template.subject
    subject_tags.each do |key,value|
      subject = subject.gsub('{'+key.to_s+'}',value)
    end
  end
          
  return subject
  end

  def self.parse_body(body_tags,template_type_id)
    email_template=Administration::EmailTemplate.find_by_email_template_types_id(template_type_id)    
    body_text = ""
    if email_template
       body_text =email_template.content
       body_tags.each do |key,value|
          body_text = body_text.gsub('{'+key.to_s+'}',value)
        end
    end          
    return body_text
  end
  
end
