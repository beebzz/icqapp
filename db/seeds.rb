# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# :password => "xyz"
Rails.application.eager_load!

User.create!(:email => 'jsommers@colgate.edu', :admin => true)
User.create!(:email => 'bboussayoud@colgate.edu', :admin => true)
User.create!(:email => 'gkong@colgate.edu', :admin => true)
User.create!(:email => 'wyi@colgate.edu', :admin => true)
User.create!(:email => 'jjakovleski@colgate.edu', :admin => true)
c101 = Course.create!(:name => 'COSC101S20', :daytime => 'TR 8:30-9:45')
attendance101 = AttendanceQuestion.create!(:qname => "Attendance check in", :course => c101)

c301 = Course.create!(:name => 'COSC301S20', :daytime => 'TR 9:55-11:10')
attendance301 = AttendanceQuestion.create!(:qname => "Attendance check in", :course => c301)

std101 = %w{
sommersmeister@gmail.com
}

puts "#{c101}"
std101.each do |email|
  std = User.create!(:email => email)
  c101.students << std
end


puts "#{c301}"
std301 = %w{
bilal.boussayoud@gmail.com
}

std301.each do |email|
  std = User.create!(:email => email)
  c301.students << std
end



exit

# dummy question seeds

Question.new # force loading model code
questions = []
options = ["Syntax error", "Runtime error", "Logic error"]
mc = MultiChoiceQuestion.create!(:qname => "What kind of error does this code exhibit?", :qcontent => options, :answer => "Logic error", :course => c)
mcp = mc.new_poll(:round => 1)
mcp.save!
fr = FreeResponseQuestion.create!(:qname => "What does this image make you think of?", :course => c)
fr.image.attach(io: File.open('testimg.png'), filename: 'testimg.png')
frp = fr.new_poll(:round => 1)
frp.save!
num = NumericQuestion.create!(:qname => "What value does this function return?", :answer => 8, :course => c)
nump = num.new_poll(:round => 1)
nump.save!

fr_resp = %w{this that other something nothing}

# don't, by default, add dummy student seeds
exit

slist = []
1.upto(10) do |i|
  s = User.create!(:email => "fakestudent#{i}@colgate.edu")
  c.students << s
  slist << s

  r = mcp.new_response(:response => options[rand(3)], :user => s)
  r.save!
  r = frp.new_response(:response => fr_resp[rand(fr_resp.length)], :user => s)
  r.save!
  r = nump.new_response(:response => rand(10), :user => s)
  r.save!
end

