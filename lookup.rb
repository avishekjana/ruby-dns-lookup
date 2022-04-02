require 'csv'
def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")
def parse_dns dns_raw
  dns_entries = []
  dns_raw.each do |row|
    data =  row.split(', ')
    unless data[1] == nil && data[2] == nil 
      dns_entries.push({ record_type: data[0], source: data[1], destination: data[2].chomp }) unless data[0] == '# RECORD TYPE'
    end
  end
  return dns_entries
end

def resolve dns_records, lookup_chain, domain
  dns_records.each do |entry|
    if entry[:source] == domain
      lookup_chain.push(entry[:destination])
      if entry[:record_type] == "CNAME"
        return resolve dns_records, lookup_chain, entry[:destination]
      end
    end
  end
  return lookup_chain
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")