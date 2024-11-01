class Queue
{
	items = null; // Table instead of array for speed (shifting arrays is expensive)
	head  = null; // Index of the first element
	tail  = null; // Index for the next element to be added

    constructor()
	{
        items = {};
        head  = 0;
        tail  = 0;
    }
	
    // Check if the queue is empty
    function isEmpty()
        return head >= tail;
		
    // Get the size of the queue
    function size()
        return tail - head;

    // Add an element to the end of the line
    function add(value)
	{
        items[tail] <- value;
        ++tail;
    }

    // Remove and return the element first in line
    function pop()
	{
        if (isEmpty())
		{
			items = {};
			head  = 0;
			tail  = 0;
            return;
		}

        local value = items[head];
        delete items[head];
        ++head; // Next in line

        return value;
    }

    // Return the element first in line
    function peek()
	{
        if (isEmpty()) return;
        return items[head];
    }
}