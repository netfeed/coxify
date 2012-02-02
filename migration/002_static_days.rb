Sequel.migration do
  up do
    create_table(:static_days) do
      primary_key :id
      column :date, Date, :null => false, :unique => true
      column :count, Integer, :default => 0
      
      index :date
    end
    
    DB[:images].select(:created_date).filter(:active => true).group(:created_date).each do |row|
      count = DB[:images].filter(:created_date => row[:created_date], :active => true).group(:md5).all.count
      DB[:static_days].insert([:date, :count], [row[:created_date], count])
    end
  end
  
  down do
    drop_table :static_days
  end
end