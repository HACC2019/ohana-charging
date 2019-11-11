public class EventList{
    public Event head;         //Points to first Event in EventList
    public int event_count;    //Total number of Events in EventList
    
    public EventList(){
        this.head = null;
        this.event_count = 0;
    }
    
    // Insert an Event into an EventList sorted by time index
    // time - The time at which the event takes place
    // type - The type of event
    public void insert(double time, int type){
        event_count++;                      //Increment number of events in list.
        Event eptr = new Event(time, type);
        if(head == null){                   //If EventList is empty,
            head = eptr;                    //put new event at head of list.
            eptr.next = null;
        }
        else if(head.time >= eptr.time){    // If the event is earlier than
            eptr.next = head;               // all existing events, place it
            head = eptr;                    // at the head of the list.
        }
        else{                               // Otherwise, search for the
            Event eindex;                   // correct location sorted by time.
            eindex = head;
            while(eindex.next != null){
                if(eindex.next.time < eptr.time){
                    eindex = eindex.next;
                }
                else{
                    break;
                }
            }
            eptr.next = eindex.next;
            eindex.next = eptr;
        }
    }
    
    // Return the Event from the head of the EventList
    public Event get(){
        if(event_count == 0){
            return null;
        }
        else {
            event_count--;
            Event eptr;
            eptr = head;
            head = head.next;
            eptr.next = null;
            return eptr;
        }
    }
    
    // Clear all Events from the EventList
    public void clear(){
        Event eptr;
        while(head!=null){
            eptr = head;
            head = head.next;
            eptr.next = null;
        }
        event_count = 0;
    }
    
    // Remove and return first event of given type
    public Event remove(int type){
        if(event_count==0 || head==null){
            return null;
        }
        else {
            Event eptr;
            Event eptr_prev = null;
            eptr = head;
            
            while(eptr!=null){
                if(eptr.type == type){
                    if(eptr_prev == null){
                        head = eptr.next;
                        eptr.next = null;
                        return eptr;
                    }
                    else{
                        eptr_prev.next = eptr.next;
                        eptr.next = null;
                        return eptr;
                    }
                }
                else{
                    eptr_prev = eptr;
                    eptr = eptr.next;
                }
            }
            return null;
        }
    }
}

