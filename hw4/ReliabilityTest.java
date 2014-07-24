import java.util.concurrent.ThreadLocalRandom;

class ReliabilityTest implements Runnable {
    private int nTransitions;
    private State state;
    private CyclicBarrier barrier;

    ReliabilityTest(int n, State s, CyclicBarrier barrier) {
	nTransitions = n;
	state = s;
	this.barrier = barrier;
    }

    public void run() {
	int n = state.size();
	if (n != 0)
	    for (int i = 0; i < nTransitions; ) {
		int a = ThreadLocalRandom.current().nextInt(n);
		int b = ThreadLocalRandom.current().nextInt(n - 1);
		if (a == b)
		    b = n - 1;
		if (state.swap(a, b))
		    i++;
	    }
	    barrier.await();
    }
}
