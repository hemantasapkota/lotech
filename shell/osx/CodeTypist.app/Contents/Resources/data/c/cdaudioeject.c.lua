return [=[
static void CDAudio_Eject(void)
{
        cdRequest->headerLength = 13;
        cdRequest->unit = 0;
        cdRequest->command = COMMAND_WRITE;
        cdRequest->status = 0;

        cdRequest->x.write.mediaDescriptor = 0;
        cdRequest->x.write.bufferOffset = readInfoOffset;
        cdRequest->x.write.bufferSegment = readInfoSegment;
        cdRequest->x.write.length = sizeof(struct reset_s);
        cdRequest->x.write.startSector = 0;
        cdRequest->x.write.volumeID = 0;

        readInfo->reset.code = WRITE_REQUEST_EJECT;

        regs.x.ax = 0x1510;
        regs.x.cx = cdrom;
        regs.x.es = cdRequestSegment;
        regs.x.bx = cdRequestOffset;
        dos_int86 (0x2f);
}
]=]
