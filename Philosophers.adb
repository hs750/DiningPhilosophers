with Ada.Text_IO; use Ada.Text_IO;
procedure Philosophers is
file : File_Type;
-- Declarations _________________________________________________________________
	numberOfPhilosophers : constant integer := 5;
	numberOfRuns : constant integer := 20;
	timeToEat : constant duration := 0.5;
	timeToThink : constant duration := 1.0;
	timeInFustration : constant duration := 0.75;
	
	type ForkPlacement is array (0..(numberOfPhilosophers-1)) of boolean;
	
	protected type Table is
		procedure takeFork(fork : in integer; available : out boolean);
		entry takePlate(plate : out boolean);
		
		procedure placeFork(fork : in integer; philHasFork : out boolean);
		entry placePlate(philHasPlate : out boolean);
		
		procedure outputState;
		private
			forks : ForkPlacement := (others => true);
			numForks : integer := numberOfPhilosophers;
			numPlates : integer := numberOfPhilosophers -  2;	
	end Table;
	
	task type Philosopher is
		entry availableForks(left : in integer; right : in integer);
	end Philosopher;
	
	philosophers : array(0..(numberOfPhilosophers -1)) of Philosopher;
	philosophicTable : Table;

-- Body _________________________________________________________________________
	-- Monitor - Table___________________________________________________________
	protected body Table is
		procedure takeFork(fork : in integer; available : out boolean) is
		begin
			if (forks(fork)) then
				forks(fork) := false;
				available := true;
				--outputState;
			else
				available := false;
				Put_Line(file, "Fork " & Integer'Image(fork) & " was not available");
			end if;
		end takeFork;
		
		entry takePlate(plate : out boolean) when numPlates > 0 is
		begin
			numPlates := numPlates - 1;
			plate := true;
			--outputState;
		end takePlate;
		
		procedure placeFork(fork : in integer; philHasFork : out boolean) is
		begin
			if (forks(fork)) then
				Put_Line(file, "THIS LINE SHOULD NEVER HAPPEN!!");
				philHasFork := true;
			else
				forks(fork) := true;
				philHasFork := false;
				--outputState;
			end if;
		end placeFork;
				
		entry placePlate(philHasPlate : out boolean) when (numPlates < (numberOfPhilosophers - 2)) is
		begin
			numPlates := numPlates + 1;
			philHasPlate := false;
			--outputState;
		end placePlate;
		
		procedure outputState is
		begin
		 
			for i in 0..(numberOfPhilosophers-1) loop
				if forks(i) then
					Put_Line(file, " Fork " & Integer'Image(i+1) & " is on the table!");
				else
					Put_Line(file, " Fork " & Integer'Image(i+1) & " is still in use!");
				end if;
			end loop;
			Put_Line(file, Integer'Image(numPlates) & " plates are in the centre of the table");
		end outputState;	
	end Table;	
	
	-- Task - Philosopher________________________________________________________
	task body Philosopher is
	
		haveLeftFork : boolean;  --philosopher in possetion of left fork?
		haveRightFork : boolean; --philosopher in possetion of right fork?
		havePlate : boolean; --whether the philosopher is in possation of a plate
		leftFork : integer; --fork to the left of the philosopher, also indicates philosophers position round the table.
		rightFork : integer; --fork to right of philosopher
		
	begin
		-- Philosopher gets alocated a seat.
		accept availableForks(left : in integer; right : in integer) do
			leftFork := left;
			rightFork := right;
		end availableForks;
		
		-- grab/eat/think loop
		for i in 1..numberOfRuns loop
			haveLeftFork := false;
			haveRightFork := false;
			havePlate := false;
			--take left then right fork - if both cant be taken place fork philosopher is in possetion of back on the table, then try again
			while (not(haveLeftFork and haveRightFork)) loop
			
				if haveLeftFork then
					philosophicTable.placeFork(leftFork, haveLeftFork);
					delay timeInFustration;
				end if;
				if haveRightFork then
					philosophicTable.placeFork(rightFork, haveRightFork);
					delay timeInFustration;
				end if;
				
				philosophicTable.takeFork(leftFork, haveLeftFork);

				philosophicTable.takeFork(rightFork, haveRightFork);	
				
			end loop;

			--take plate
			if (not havePlate) then
				philosophicTable.takePlate(havePlate);
			end if;

			Put_Line(file, "Philosopher" & Integer'Image(leftFork) & 
				" is eating for the " & Integer'Image(i) &"th time...");
			delay timeToEat;
			Put_Line(file, "Philosopher" & Integer'Image(leftFork) & 
				" finnished eating for the " & Integer'Image(i) & "th time!");
			
			philosophicTable.placeFork(leftFork, haveLeftFork);
			philosophicTable.placeFork(rightFork, haveRightFork);
			philosophicTable.placePlate(havePlate);
			
			Put_Line(file, "Philosopher" & Integer'Image(leftFork) & 
				" is thinking for the " & Integer'Image(i) & "th time...");
			delay timeToThink;
			Put_Line(file, "Philosopher" & Integer'Image(leftFork) & 
				" has finished thinking for the " & Integer'Image(i) & "th time!");
			
			Put_Line(file, "Philosopher " & Integer'Image(leftFork) & " completed loop " & Integer'Image(i));
			Put_Line("Philosopher " & Integer'Image(leftFork) & " completed loop " & Integer'Image(i));
		end loop;
	end;
	
-- Main _________________________________________________________________________
modulo : integer := 0;
begin
 	Create(file, Out_File, "out.txt");	
	-- Tell each philosopher where he is sitting
	for i in 0..(numberOfPhilosophers -1) loop
	 	philosophers(i).availableForks(i, ((i+1) mod numberOfPhilosophers));
	end loop;
	
end Philosophers;