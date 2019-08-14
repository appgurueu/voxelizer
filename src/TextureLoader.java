import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.awt.image.DataBuffer;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

public class TextureLoader {

    /* Takes two file paths as inputs : Input and output. Input file needs to be a supported image, and output needs to be writable. Image will be stored in output using SIF file format.*/
    public static void main(String... args) {
        if (args.length < 2) {
            System.out.println("Output and input path need to be given");
            System.exit(1);
        } else {
            File in = new File(args[0]);
            File out = new File(args[1]);
            if (!out.exists()) {
                try {
                    out.createNewFile();
                } catch (IOException e) {
                    System.out.println("Couldn't create output file");
                    System.exit(2);
                }
            }
            if (!in.exists() || !in.canRead() || !out.canWrite()) {
                System.out.println("Output or input file doesn't exist or can't be read/written");
                System.exit(3);
            }
            try {
                BufferedImage img = ImageIO.read(in);
                FileOutputStream outputStream = new FileOutputStream(out);

                /* Write headers */
                outputStream.write(img.getWidth()/256);
                outputStream.write(img.getWidth()%256);
                outputStream.write(img.getHeight()/256);
                outputStream.write(img.getHeight()%256);

                /* Write data */
                for (int y = 0; y < img.getHeight(); y++) {
                    for (int x = 0; x < img.getWidth(); x++) {
                        int color = img.getRGB(x, y);
                        int alpha = color >>> 24;
                        int red = (color & 0x00FF0000) >> 16;
                        int green = (color & 0x0000FF00) >> 8;
                        int blue = color & 0x000000FF;
                        outputStream.write(alpha);
                        outputStream.write(red);
                        outputStream.write(green);
                        outputStream.write(blue);
                    }
                }

                outputStream.close();
            } catch (IOException e) {
                System.out.println("File couldn't be written");
                System.exit(4);
            }
        }
    }
}