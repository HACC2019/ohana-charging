public class Main{
  private static double Seed = 1111.0;

  public static double uni_rv(){
      double k = 16807.0;
      double m = 2.147483647e9;
      double rv;

      Seed = (k*Seed)%m;	
      rv=Seed/m;
      return(rv);
  }

  public static double exp_rv(double lambda)
  {
      double exp;
      exp = ((-1) / lambda) * Math.log(uni_rv());
      return(exp);
  }

  // Simulates an M/M/1 queueing system.  The simulation terminates
  // once 10 000 customers depart from the system.
  public static void main(String[] args){
    EventList Elist = new EventList();
      final int ARR = 1;
      final int DEP = 0;
      //station capacity
      int k = 4;
      //# of charger
      int m = 1;
      //total programs
      int total = 0;
      // number of Event block
      int numBlock = 0;
      double mu = 0.00051;                // Service rate 0.00051 jobs/second //mu = 1/mean duration(in seconds)
      double lambda = 113;            // Arrival rate, we expect 113 sessions in a week (this based on the last week)

      double clock = 0.0;             // System clock
      int N = 0;                      // Number of customers in system
      int Ndep = 0;                   // Number of departures from system
      double EN = 0.0;                // For calculating E[N]

      boolean done = false;                   // End condition satisfied?

      Event CurrentEvent;

      Elist.insert(exp_rv(lambda),ARR); // Generate first arrival event

      while (!done){
        CurrentEvent = Elist.get();               // Get next Event from list
        double prev = clock;                      // Store old clock value
        clock=CurrentEvent.time;                 // Update system clock 

        switch (CurrentEvent.type) {
        case ARR:                                 // If arrival
          if (N < k){// if memory is not full
            N++;
            total++;
            Elist.insert(clock+exp_rv(mu),ARR); //generate arrival
          }
          else{
            numBlock++;
            total++;
            Elist.insert(clock+exp_rv(mu),ARR); //generate arrival
          }
          if (m>0){  // if a processor is free
            m--;
            Elist.insert(clock+exp_rv(mu),DEP); //generate departure
          }
          break;
        case DEP:                                 // If departure
          m++;
          EN += N*(clock-prev);                   //  update system statistics
          N--;                                    //  decrement system size
          Ndep++;                                 //  increment num. of departures
          if (N > 1) {                            // If customers remain
            Elist.insert(clock+exp_rv(mu),DEP);//  generate next departure
            m--;
          } 
          break;
        }
        //put average sessions daily here
        if (Ndep > 10000) done=true;        // End condition is the number of sessions you would like to test, Ex: I picked 10 000 sessions, the outcome will be
                                            // whether the station is congested after serving 10 000 customers
      }
    // output simulation results
    System.out.println("This simulation based on a station with 1 charger and 3 waiting slots, if the waiting slots is full, arriving customer will be blocked and they will leave");
    System.out.printf("Average time a customer spends in the station (simulation): %f hours\n", (EN/(clock*lambda)*7*24));
  }
}
