import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;

public class FileDownloader {
    // Takes URL to file and downloads it to given destination
    public static void main(String[] args) {
        if (args.length < 2) {
            System.out.println("URL and output path need to be given");
            System.exit(1);
        } else {
            try {
                URL in = new URL(args[0]);
                File out = new File(args[1]);
                if (!out.exists()) {
                    try {
                        out.createNewFile();
                    } catch (IOException e) {
                        System.out.println("Couldn't create file");
                        System.exit(2);
                    }
                }
                if (!out.canWrite()) {
                    System.out.println("Output file doesn't exist or can't be written");
                    System.exit(3);
                }
                try {
                    FileOutputStream outStream = new FileOutputStream(out);
                    try {
                        ReadableByteChannel download = Channels.newChannel(in.openStream());
                        outStream.getChannel().transferFrom(download, 0, Long.MAX_VALUE);
                    } catch (IOException e) {
                        System.out.println("Couldn't download file");
                        System.exit(4);
                    }
                } catch (FileNotFoundException e) {
                    System.out.println("Couldn't write to file");
                    System.exit(5);
                }
            } catch (MalformedURLException e) {
                System.out.println("Malformed URL");
                System.exit(6);
            }
        }
    }
}
