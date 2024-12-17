public class PropertyPrint {
    public static void main(String[] args) {
        if(null == args || 0 == args.length) {
            args = new String[] { "java.version" };
        }

        for(int i=0; i<args.length; ++i) {
            String property = args[i];

            if(i > 0) {
                System.out.print(' ');
            }

            System.out.print(System.getProperty(property));
        }
        System.out.println();
    }
}
