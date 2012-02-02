Sequel.migration do
  up do
    alter_table(:images) do 
      add_index :active
      add_index :channel_id
    end
    
    alter_table(:channels) do
      add_index :network_id
    end
  end
  
  down do
    alter_table(:images) do 
      drop_index :active
      drop_index :channel_id
    end
    
    alter_table(:channels) do
      drop_index :network_id
    end
  end
end