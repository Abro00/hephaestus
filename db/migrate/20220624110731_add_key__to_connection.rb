class AddKeyToConnection < ActiveRecord::Migration[7.0]
  def change
    add_column :connections, :project_key, :string
  end
end
