public class PlatformEventsTestUtil {
    private static Boolean shouldForceException = false;
    private static Boolean isCatchableException = false;
    private static Boolean isContinuous = false;
    private static Integer runCounter = 0;
    private static Integer exceptionThrownAtRun = 0;
    
    public class MyCustomException extends Exception {}
    
    // Throws a limit exception at a specific trigger run.
    // The test method calls this utility method.
    public static void throwLimitExceptionAtRun(Integer exThrownAtRun) {
        enableExceptionForTesting(false, exThrownAtRun, false);
    }
    
    // Throws a catchable exception at a specific trigger run.
    // The test method calls this utility method.
    public static void throwCatchableExceptionAtRun(Integer exThrownAtRun) {
        enableExceptionForTesting(true, exThrownAtRun, false);
    }
    
    // Throws a catchable exception starting at a specific trigger run
    // and keeps throwing it again.
    // The test method calls this utility method.
    public static void throwCatchableExceptionContinuousAtRun(Integer exThrownAtRun) {
        enableExceptionForTesting(true, exThrownAtRun, true);
    }
    
    // Sets up the test parameters.
    private static void enableExceptionForTesting(Boolean isCatchableEx,
                                                 Integer exThrownAtRun,
                                                 Boolean isCont) {
        if (Test.isRunningTest()) {
            shouldForceException = true;
            isCatchableException = isCatchableEx;
            isContinuous = isCont;
            runCounter = 0;
            exceptionThrownAtRun = exThrownAtRun;
        }
    }
    
    // Enables testing of exceptions in an Apex trigger.
    // Runs only in test context.
    // The Apex trigger calls this method.
    public static void forceExceptionForTesting() {
        if (Test.isRunningTest() && shouldForceException) {
            runCounter++;
            System.debug('runCounter=' + runCounter);
            
            Boolean shouldThrowException = (runCounter == exceptionThrownAtRun) ||
                (runCounter >= exceptionThrownAtRun && isContinuous);
            
            if (shouldThrowException) {
                if (isCatchableException) {
                    System.debug('Throwing a catchable exception.');
                    throw new MyCustomException();
                } else {
                    System.debug('Throwing a limit exception.');
                    throw new System.LimitException();
                }
            }
        }
    }
    
    // Cleans up the test parameters. The test method calls this method.
    public static void cleanUp() {
        shouldForceException = false;
        isCatchableException = false;
        isContinuous = false;
        runCounter = 0;
        exceptionThrownAtRun = 0;
    }
    
    public static Integer getRunCounter() {
        return runCounter;
    }
}