module CommandHelpers
  def invoke_tasks(instance, *task_names)
    task_names.each do |task_name|
      cmd = instance.class.all_commands[task_name.to_s]
      next unless cmd
      instance.invoke_command cmd
    end
  end
end
