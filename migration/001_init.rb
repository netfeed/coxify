Sequel.migration do 
  up do 
    create_table(:networks) do
      primary_key :id
      column :name, String, :null => false, :unique => true
      column :slug, String, :null => false
      column :address, String
      column :port, Integer, :default => 6667
      column :active, TrueClass, :default => true, :null => false
      
      index :id
    end
    
    create_table(:channels) do
      primary_key :id
      column :name, String, :null => false
      column :active, TrueClass, :default => true, :null => false
      foreign_key :network_id, :networks, :null => false
      
      index :id
    end
    
    create_table(:images) do
      primary_key :id
      column :md5, String, :size => 32, :null => false
      column :size, Integer, :null => false
      column :width, Integer, :null => false
      column :height, Integer, :null => false
      column :original_url, String
      column :pretty_url, String
      column :created_date, Date, :null => false
      column :created_time, Time, :null => false, :only_time=>true
      column :updated, DateTime, :null => false
      column :user, String
      column :active, TrueClass, :default => true, :null => false
      foreign_key :channel_id, :channels, :null => false
      
      index :created_date
      index :created_time
      index :md5
      index :id
    end
  end
  
  down do
    drop_table :images
    drop_table :channels
    drop_table :networks
  end
end