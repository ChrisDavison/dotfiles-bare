function backup_todos
cp $TODOFILE /media/nas/archive/todos/todo.txt-(date +"%F-%H%M%S")
cp $DONEFILE /media/nas/archive/todos/done.txt-(date +"%F-%H%M%S")
end
